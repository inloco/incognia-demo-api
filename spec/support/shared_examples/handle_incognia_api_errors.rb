shared_examples_for 'handle Incognia API errors' do
  context 'when API returns 404' do
    before do
      allow(service).to receive(method)
        .and_raise(Incognia::APIError.new('', status: 404))
    end

    it "returns http not found" do
      dispatch_request

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when API returns 400' do
    before do
      allow(service).to receive(method)
        .and_raise(Incognia::APIError.new('', status: 400, body: error_message))
    end
    let(:error_message) { { errors: 'Some error'}.to_json }

    it "returns http 422" do
      dispatch_request

      expect(response).to have_http_status(422)
    end
  end

  context 'when API returns other error' do
    before do
      allow(service).to receive(method)
        .and_raise(Incognia::APIError.new(''))
    end

    it "returns http internal error" do
      dispatch_request

      expect(response).to have_http_status(:error)
    end
  end
end
