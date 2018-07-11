class UsersHelperTest < ActionView::TestCase
  test "beautyofcode account exist" do
    class MockResponse
      def code
        200
      end

      def body
        JSON.parse(file_fixture('eos_get_account_response_success.json').read)
      end
    end

    Typhoeus::Request.stub_any_instance :run, MockResponse.new do
      assert eos_account_exist?('beautyofcode')
    end
  end

  test "beautyofcode account non exist" do
    class MockResponse
      def code
        500
      end

      def body
        JSON.parse(file_fixture('eos_get_account_response_not_exist.json').read)
      end
    end

    Typhoeus::Request.stub_any_instance :run, MockResponse.new do
      assert_not eos_account_exist?('beautyofcode')
    end
  end

  test "should fail to create already exist eos account" do
    class MockResponse
      def code
        500
      end

      def body
        JSON.parse(file_fixture('eos_create_account_response_already_exist.json').read)
      end
    end

    account_name = 'chainpartner'
    pubkey = 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3'

    Typhoeus::Request.stub_any_instance :run, MockResponse.new do
      response = create_eos_account(account_name, pubkey)
      assert_equal 500, response.code
    end
  end
end
