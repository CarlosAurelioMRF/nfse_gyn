require 'spec_helper'
require 'savon/mock/spec_helper'

RSpec.describe NfseGyn::GerarNfse do
  include Savon::SpecHelper

  subject { described_class.new(nota_fiscal_info) }

  let(:nota_fiscal_info) { {} }

  before(:all) { savon.mock! }
  after(:all)  { savon.unmock! }

  describe '#to_xml' do
    it 'should call GerarNfseXML builder class' do
      expect_any_instance_of(NfseGyn::GerarNfseXML).to receive(:to_xml).once
      subject.to_xml
    end
  end

  describe '#execute!' do
    let(:xml_payload) { File.read(fixture_file_path('xmls/valid_gerar_nfse_request.xml')) }
    let(:request_payload) { "<ArquivoXML><![CDATA[#{xml_payload}]]></ArquivoXML>" }

    before do
      allow(subject).to receive(:to_xml).and_return(xml_payload)
      savon.expects(:gerar_nfse).with(message: request_payload).returns(response)
    end

    context 'valid request' do
      let(:response) { File.read(fixture_file_path('xmls/valid_gerar_nfse_response.xml'))}

      it 'returns a valid response' do
        expect(subject.execute!).to be_successful
      end
    end

    context 'invalid request' do
      let(:response) { File.read(fixture_file_path('xmls/invalid_gerar_nfse_response.xml'))}

      it 'returns a invalid response' do
        expect(subject.execute!).to_not be_successful
      end

      it 'returns a error message' do
        expect(subject.execute!.error_message).to eq('Para essa Inscrição Municipal/CNPJ já existe um RPS informado com o mesmo número, série e tipo.')
      end
    end
  end
end
