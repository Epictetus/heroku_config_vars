require 'spec_helper'

module HerokuConfigVars
  describe HerokuApp do

    let(:app_name) { 'valid-app-name' }
    let(:api_key)  { 'valid-api-key' }
    let(:auth)     { 'Basic ' << Base64::strict_encode64(':' << api_key) }

    before do
      stub_request(:get, "https://api.heroku.com/apps/#{app_name}/config_vars").
        with(:headers => {'Authorization'=>auth}).
        to_return(:body => <<-RESPONSE
          {
            "DATABASE_URL": "postgres://xxx:xxx@ec2-54-243-229-75.compute-1.amazonaws.com:5432/d26ti1mqt7h24",
            "HEROKU_POSTGRESQL_MAROON_URL": "postgres://xxx:xxx@ec2-54-243-229-75.compute-1.amazonaws.com:5432/d26ti1mqt7h24",
            "HEROKU_APP_NAME": "#{app_name}",
            "HEROKU_API_KEY": "#{api_key}"
          }
        RESPONSE
        )
    end

    describe '::find' do
      subject { described_class.find }

      context 'without ENV set' do
        before do
          ENV.delete 'HEROKU_APP_NAME'
          ENV.delete 'HEROKU_API_KEY'
        end

        it { should be_a_kind_of HerokuApp }
        its(:app_name) { should be_nil }
        its(:api_key) { should be_nil }

        specify('no request made') do
          expect(a_request :any, "api.heroku.com").not_to have_been_made
        end
      end

      context 'with valid ENV set' do
        before do
          ENV['HEROKU_APP_NAME'] = app_name
          ENV['HEROKU_API_KEY']  = api_key
        end

        it { should be_a_kind_of HerokuApp }
        it { should be_loaded }

        its(:api_key) { should eq api_key }
        its(:app_name) { should eq app_name }        
      end

    end

    describe '::new' do
      subject { described_class.new args }

      context 'with no args' do
        let(:args) do
          {}
        end

        it { should_not be_valid }
        it { should have(1).error_on(:app_name) }
        it { should have(1).error_on(:api_key) }
        it { should_not be_loaded }
        its(:vars) { should be_empty }
      end

      context 'with valid credentials' do
        let(:args) do
          {
            :api_key  => api_key,
            :app_name => app_name,
          }
        end

        it { should be_valid }
        it { should_not be_loaded }
        its(:vars) { should include 'HEROKU_APP_NAME' }
        its(:vars) { should include 'HEROKU_API_KEY' }
      end
    end

    describe '#attributes=' do
      subject(:app) { described_class.new }
      before { app.attributes = {:api_key => 'foo'} }

      its(:api_key) { should eq 'foo' }
    end

    describe '#load_vars' do
      context 'with non-existent app name'
      context 'with unauthorized app name'
      context 'with invalid api key'
      context 'with no config set'
      context 'with config'
    end

    describe '#save'

    context 'with changed `vars`' do
      before do
        stub_request(:get, "https://api.heroku.com/apps/#{app_name}/config_vars").
          with(headers: {'Authorization'=>auth}).
          to_return(headers: {
            'Content-Type' => 'application/json'
          }, body: <<-RESPONSE
            {
              'VAR1': 'value 1',
              'VAR2': 'value 2',
              'VAR3': 'value 3',
              'VAR4': 'value 4',
            }
          RESPONSE
          )
      end

      let(:app) { described_class.new(api_key: api_key, app_name: app_name) { |app| app.load_vars } }

      before do
        puts app.vars
        app.vars = {
          'VAR2' => 'value 2',
          'VAR3' => 'value 33',
          'VAR4' => 'value 44',
          'VAR5' => 'value 5'
        }
      end

      describe '#removed_vars'
      describe '#added_vars'
      describe '#kept_vars'
      describe '#updated_vars'
      describe '#updated_and_added_vars'
      describe '#changes'
    end

#    context 'with an invalid api_key' do
#      let(:args) do
#        {
#          :api_key  => 'xxx',
#          :app_name => app_name,
#        }
#      end
#
#      it { should_not be_valid }
#      it { should have(1).error_on(:api_key) }
#    end
#
#    context 'with an invalid app_name' do
#      let(:args) do
#        {
#          :api_key  => api_key,
#          :app_name => 'xxx',
#        }
#      end
#
#      it { should_not be_valid }
#      it { should have(1).error_on(:app_name) }
#    end
#    specify('no request made') do
#      expect(a_request :any, "api.heroku.com").not_to have_been_made
#    end
#
#    context 'with an invalid ENV' do
#      before do
#        ENV['HEROKU_APP_NAME'] = 'xxx'
#        ENV['HEROKU_API_KEY']  = 'xxx'
#      end
#
#      it { should be_a_kind_of HerokuApp }
#      it { should be_loaded }
#
#      its(:vars) { should be_present }
#      its(:api_key) { should eq api_key }
#      its(:app_name) { should eq app_name }
#      its(:errors) { should be_blank }
#    end


  end
end
