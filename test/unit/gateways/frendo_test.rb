require 'test_helper'

class FrendoTest < Test::Unit::TestCase
  def setup
    @gateway = FrendoGateway.new(
                 :login => 'myUsername@frendo.com',
                 :password => 'password'
               )

    @credit_card = credit_card
    @amount = 100
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card)
    assert_instance_of Response, response
    assert_success response

    # Replace with authorization number from the successful response
    assert_equal '12345678901', response.authorization
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card)
    assert_failure response
    assert response.test?
  end

  private

  # Place raw successful response from gateway here
  def successful_purchase_response
    {
      'Ok' => 'Ok',
      'Errors' => [ { 'Code' => '0', 'Message' => 'No errors' } ],
      'Data' => { 'ConfirmationNumber' => '12345678901' }
    }
  end

  # Place raw failed response from gateway here
  def failed_purchase_response
    {
      'Ok' => '0',
      'Errors' => [ { 'Code' => '1000', 'Message' => 'An internal error occurred. Please retry the transaction.' } ],
      'Data' => { }
    }
  end
end
