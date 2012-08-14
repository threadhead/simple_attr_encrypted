require 'active_record'
require 'active_support'

module ActiveRecord
  module SimpleAttrEncrypted
    extend ::ActiveSupport::Concern


    module ClassMethods
      def encrypted_attribute(attribute)
        attribute_name = "encrypted_#{attribute}"

        attr_accessible attribute.to_sym
        attr_accessible attribute_name.to_sym
        attr_accessible "#{attribute_name}_iv".to_sym

        define_method("#{attribute}=") do |value|
          iv = send("#{attribute_name}_iv")
          encrypted_value = encrypt_string(value, iv)
          send("#{attribute_name}=", encrypted_value)
          instance_variable_set("@#{attribute}", value)
        end

        define_method(attribute.to_sym) do
          iv = send("#{attribute_name}_iv")
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", decrypt_string(send(attribute_name.to_sym), iv))
        end

        before_save "generate_#{attribute_name}_iv".to_sym, if: :new_record?

        define_method("generate_#{attribute_name}_iv".to_sym) do
          send("#{attribute_name}_iv=".to_sym, random_iv)
        end
      end
    end


    private
      def encrypt_string(value, iv)
        if value.nil? || value.empty?
          value
        else
          Base64.encode64(cipher_crypt(:encrypt, value, iv))
        end
      end


      def decrypt_string(value, iv)
        (value.nil? || value.empty?) ? value : cipher_crypt(:decrypt, Base64.decode64(value), iv)
      end


      def cipher_crypt(cipher_method, value, iv)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.send(cipher_method)
        cipher.iv = iv
        cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(ENV['ENCRYPTED_ATTRIBUTE_KEY'], ENV['ENCRYPTED_ATTRIBUTE_SALT'], 2000, cipher.key_len)
        cipher.update(value) + cipher.final
      end


      def random_iv
        Base64.encode64(OpenSSL::Cipher::Cipher.new('aes-256-cbc').random_iv).chomp
      end

  end
end
