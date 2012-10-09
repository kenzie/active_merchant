require 'json'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FrendoGateway < Gateway
      self.test_url = 'https://test10.frendo.com/FrendoAPI/api/v1/'
      self.live_url = 'https://www.frendo.com/FrendoAPI/api/v1/'

      self.supported_countries = ['US','CA']
      self.default_currency = 'CAD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      self.homepage_url = 'http://www.frendo.com/'
      self.display_name = 'Frendo'

      def initialize(options = {})
        @options = options
        super
      end

      def purchase(money, creditcard, options = {})
        post = {}
        add_charity_type(post)
        add_address(post, options)
        add_credit_card(post, creditcard)
        add_invoice(post, money)
        add_user(post, options)

        commit('order.create', post)
      end

      private

      def add_charity_type(post)
        post['Charity'] = {}
        post['Charity']['Type'] = "Charity"
        post['Charity']['Id']   = "2"
      end

      def add_address(post, options)
        if address = options[:billing_address] || options[:address]
          post['Address'] = {}
          post['Address']['Address']     = address[:address1].to_s
          post['Address']['City']        = address[:city].to_s
          post['Address']['Province']    = address[:state].to_s
          post['Address']['State']       = address[:state].to_s
          post['Address']['PostalCode']  = address[:zip].to_s
          post['Address']['Country']     = address[:country].to_s
          post['BillingAddress'] = post['Address']
        end
      end

      def add_credit_card(post, creditcard)
        post['CreditCard'] = {}
        post['CreditCard']['CardType']        = 'VI'
        post['CreditCard']['CardNumber']      = creditcard.number
        post['CreditCard']['CardholderName']  = "#{creditcard.first_name} #{creditcard.last_name}"
        post['CreditCard']['ExpiryMonth']     = creditcard.month.to_s
        post['CreditCard']['ExpiryYear']      = creditcard.year.to_s
        post['CreditCard']['Cvv']             = creditcard.verification_value if creditcard.verification_value?
      end

      def add_invoice(post, money)
        post['Order'] = {}
        post['Order']['Amount']   = money
        post['Order']['OrderDate']     = Time.now.strftime('%Y/%m/%d')
        post['Order']['OrderType']     = 'CC'
      end

      def add_user(post, options)
        post['UserInfo'] = {}
        post['UserInfo']['FirstName']     = 'John'
        post['UserInfo']['LastName']      = 'Doe'
        post['UserInfo']['PhoneNumber']   = '9025551212'
        post['UserInfo']['Email']         = 'john.doe@example.com'
        post['UserInfo']['HostAddress']   = '123.123.123.123'
      end

      def commit(action, parameters)
        response = JSON.parse(ssl_post(test? ? self.test_url+action : self.live_url+action, parameters.to_json))

        Response.new(success?(response),
                     message_from(response),
                     response,
                     :test => test?,
                     :authorization => authorization_from(response))
      end

      def authorization_from(response)
        response['Data']['ConfirmationNumber'] if response['Data'] && response['Data']['ConfirmationNumber']
      end

      def message_from(response)
        response['Errors'][0]['Message']
      end

      def success?(response)
        response['Ok'] == '1'
      end

    end
  end
end

