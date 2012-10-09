require 'test_helper'

class RemoteFrendoTest < Test::Unit::TestCase


  def setup
    Base.mode = :test
    @gateway = FrendoGateway.new(fixtures(:frendo))

    @amount = 100
    @credit_card = credit_card('4715320629000001')
    @declined_card = credit_card('4715320629000002')

    @options = { }
  end

  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'Success', response.message
  end

  # def test_unsuccessful_purchase
  #   assert response = @gateway.purchase(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end

  # def test_invalid_login
  #   gateway = FrendoGateway.new(
  #               :login => '',
  #               :password => ''
  #             )
  #   assert response = gateway.purchase(@amount, @credit_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
  # end
end
