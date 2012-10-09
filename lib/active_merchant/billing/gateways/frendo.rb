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
        add_billing_address(post, options)
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
        post['Address'] = {}
        post['Address']['Address']     = '123 Maint St.'
        post['Address']['City']        = 'Southwest Mabou'
        post['Address']['Province']    = 'Nova Scotia'
        post['Address']['PostalCode']  = 'B0E 2W0'
        post['Address']['State']       = ''
        post['Address']['Country']     = 'CN'
      end

      def add_billing_address(post, options)
        post['BillingAddress'] = {}
        post['BillingAddress']['Address']     = '123 Maint St.'
        post['BillingAddress']['City']        = 'Southwest Mabou'
        post['BillingAddress']['Province']    = 'Nova Scotia'
        post['BillingAddress']['PostalCode']  = 'B0E 2W0'
        post['BillingAddress']['State']       = ''
        post['BillingAddress']['Country']     = 'CN'
      end

      def add_credit_card(post, creditcard)
        post['CreditCard'] = {}
        post['CreditCard']['CardNumber']      = creditcard.number
        post['CreditCard']['CardholderName']  = "#{creditcard.first_name} #{creditcard.last_name}"
        post['CreditCard']['ExpiryMonth']     = creditcard.month
        post['CreditCard']['ExpiryYear']      = creditcard.year
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
        response = ssl_post(test? ? self.test_url+action : self.live_url+action, parameters.to_json)

        Response.new(success?(response),
                     message_from(response),
                     parse(response),
                     :test => test?,
                     :authorization => response['Data']['ConfirmationNumber'])
      end

      def message_from(response)
        return response['Errors'][0]['Message'] unless success?(response)
        "Success"
      end

      def parse(response)
        {
          :ok => response['Ok'],
          :error_code => response['Errors'][0]['Code'],
          :error_message => response['Errors'][0]['Message'],
          :authorization => response['Data']['ConfirmationNumber'],
          :complete => response
        }
      end

      def success?(response)
        response['Ok'] == 'Ok'
      end

    end
  end
end

