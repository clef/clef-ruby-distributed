# Clef for Ruby

The Clef Ruby library encapsulates the entire distributed validation flow in a few, easy-to-use functions. 

## Configuring the library

You'll need to configure the Ruby library with your website's private key, app ID and app secret. For Rails, you should add the following to `config/initializers/clef.rb`: 

    Clef.configure do |config|
      config.id = YourWebsite::Application.config.clef_id
      config.secret = YourWebsite::Application.config.clef_secret
      config.passphrase = 'your private key passphrase'
      config.keypair = File.read(File.join(File.dirname(__FILE__), '..', 'keys', 'yourprivatekey.pem'))
    end

*config.id* is your website's app ID, which you generated in the Clef dashboard when you created your integration. 

*config.secret* is your website's app ID, which you generated in the Clef dashboard when you created your integration. 

*config.passphrase* (optional) is an optional passphrase that protects your website's keypair. You can set a passphrase when you generate your keypair using ssh-keygen or openssl. 

*config.keypair* is a string representation of your keypair's PEM-formatted private key. Your private key may be encrypted if you set a passphrase when you generated your keypair. 

## Constructing the login payload

After you complete the OAuth handshake, the library will construct, sign, and serialize a valid payload for you.

First, construct the payload: 

    # Following the OAuth handshake, we create or look up a user with the
    # information returned by Clef. Since auth_hash contains a user's public key,
    # a newly created user should be created with the public key.
    @user = User.find_or_create_from_auth_hash(auth_hash)

    payload = {
        nonce: SecureRandom.hex(24),
        clef_id: @user.clef_id,
        redirect_url: 'http://yourwebsite.com/clef/confirm',
        session_id: session_id
    }

    # We store the payload in the browser session so we can verify the nonce later
    session['clef_payload'] = payload

You can then sign the payload: 

    signed_payload = Clef.sign_login_payload(payload)

The Clef library will take care of properly serializing the payload to `payload_json`, generating a `SHA256` hash and signing it. 

Finally, you can serialize the payload to base64 and redirect the browser: 

    redirect_to "#{Rails.application.config.CLEF_BASE}/api/v1/validate?payload=#{Clef.encode_payload(signed_payload)}"

## Verifying the user-signed payload after a user confirms login

When the browser redirects to your distributed validation `redirect_url`, you'll receive the payload bundle you sent to Clef, signed by the user. We can use the library to validate and verify the user's signature.

First, we decode the payload and check it against the nonce we generated: 

    payload_bundle = Clef.decode_payload params[:payload]
    signed_payload = JSON.parse payload_bundle[:payload_json], symbolize_names: true

    session_payload = session[:clef_payload]
    payload_is_valid = session_payload.present? and signed_payload.present? and session_payload[:nonce] == signed_payload[:nonce]

    if payload_is_valid
        session.delete(:clef_payload)
    else
        # Show an error message to the user
    end

Then, we verify that the payload is signed by the user's private key: 

    @user = User.find_by_clef_id(signed_payload[:clef_id])
    Clef.verify_login_payload!(payload_bundle, @user.public_key)

`verify_login_payload!` validates the payload, verifies that it originated from your website by verifying with your website's public key, and verifies that the user signed it. If it fails, it will throw an exception of the type `Clef::Errors::VerificationError` with a message indicating the error. 

If verification succeeds, you can log the user in as you normally would. 

## The Reactivation Webhook

When Clef triggers your reactivation webhook, the Clef library handles the handshake for you. 

In your reactivation webhook endpoint, first grab the reactivation_token: 

    reactivation_token = params[:reactivation_token]

Then, retrieve reactivation information: 

    reactivation_payload = Clef.get_reactivation_payload(reactivation_token)

`get_reactivation_payload` exchanges the token for information and then verifies that the information was signed by the initiation and confirmation keys. 

After successfully calling `get_reactivation_payload`, you can update your user with a new public key then return an empty `200` response: 

    @user = User.find_by_clef_id(reactivation_payload[:clef_id])
    if @user.public_key == reactivation_payload[:public_keys][:previous][:bundle]
        @user.public_key = reactivation_payload[:public_keys][:current][:bundle]
        @user.save!
        render text: ""
    end

