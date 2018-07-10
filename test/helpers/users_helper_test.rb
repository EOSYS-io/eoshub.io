class UsersHelperTest < ActionView::TestCase
  test "EOSIO account exist" do
    assert eos_account_exist?('eosio')
  end

  test "beautyofcode account non exist" do
    assert_not eos_account_exist?('beautyofcode')
  end

  test "should fail to create already exist eos account" do
    account_name = 'chainpartner'
    pubkey = 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3'
    response = create_eos_account(account_name, pubkey)

    assert_equal 500, response.code
  end
end
