require 'rails_helper'
require 'rails/generators'
require_relative File.expand_path("../../lib/generators/jsonapi/serializable/serializable_generator.rb", __FILE__)

describe Jsonapi::SerializableGenerator do
  with_model :User, superclass: ApplicationRecord, scope: :all do
    table do |t|
      t.string :name
      t.string :email
    end
  end

  before do
    @test_case = Rails::Generators::TestCase.new(:fake_test_case)
    @test_case.class.tests(described_class)
    @test_case.class.destination(File.expand_path("../tmp", File.dirname(__FILE__)))
    @test_case.send(:prepare_destination)
  end

  context "passing an existent model" do
    let(:model_name) { "User" }

    it "creates a serializable resource" do
      @test_case.assert_no_file "app/serializable/serializable_user.rb"
      @test_case.run_generator([model_name])
      @test_case.assert_file "app/serializable/serializable_user.rb", /SerializableUser/
    end
  end

  context "passing an nonexistent model" do
    let(:model_name) { "Dummy" }

    it "raises an error" do
     expect { @test_case.run_generator([model_name]) }.to raise_error(RuntimeError, "Dummy model not found.")
    end

    it "does not create a serializable resource" do
      @test_case.assert_no_file "app/serializable/serializable_dummy.rb" do
        @test_case.run_generator([model_name])
      end
    end
  end
end
