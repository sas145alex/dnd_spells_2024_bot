RSpec.describe "GET /admin/mentions/options_for_select" do
  subject(:make_request) do
    get "/admin/mentions/options_for_select", params: params
  end

  let(:params) do
    {mentionable_type: mentionable_type}
  end

  let(:operation) { Mention::GenerateOptionsForSelect }

  let(:expected_json) do
    {
      pagination: {more: false},
      results: mocked_results
    }
  end
  let(:mocked_results) do
    [
      {id: 123, text: "title"},
      {id: 122, text: "title 2"}
    ]
  end

  before do
    allow(operation).to receive(:call).and_return(mocked_results)
  end

  context "when user is authenticated" do
    let(:admin) { create(:admin_user) }

    before { sign_in(admin) }

    context "when mentionable_type cannot be constantize" do
      let(:mentionable_type) { "invalid+input" }

      it "returns and empty array" do
        make_request

        expect(response.status).to eq(200)
        expect(json_body).to eq(expected_json)
      end

      it "calls operation with proper params" do
        make_request

        expect(operation).to have_received(:call).with(mentionable_klass: nil)
      end
    end

    context "when mentionable_type can be constantize" do
      let(:mentionable_type) { "Spell" }

      it "returns and empty array" do
        make_request

        expect(response.status).to eq(200)
        expect(json_body).to eq(expected_json)
      end

      it "calls operation with proper params" do
        make_request

        expect(operation).to have_received(:call).with(mentionable_klass: Spell)
      end
    end

    context "when mentionable_type can be constantize" do
      let(:mentionable_type) { "Origin" }

      it "returns and empty array" do
        make_request

        expect(response.status).to eq(200)
        expect(json_body).to eq(expected_json)
      end

      it "calls operation with proper params" do
        make_request

        expect(operation).to have_received(:call).with(mentionable_klass: Origin)
      end
    end

    context "when mentionable_type can be constantize" do
      let(:mentionable_type) { "Feat" }

      it "returns and empty array" do
        make_request

        expect(response.status).to eq(200)
        expect(json_body).to eq(expected_json)
      end

      it "calls operation with proper params" do
        make_request

        expect(operation).to have_received(:call).with(mentionable_klass: Feat)
      end
    end
  end
end
