require 'spec_helper'

class ViewWithResourcesControllerHelper < ActionView::Base
  include ResourcesController::Helper
end

describe "ActionView with resources_controller Helper" do
  before do
    @view = ViewWithResourcesControllerHelper.new
    @controller = double('Controller')
    @view.controller = @controller
  end
  
  def self.it_should_forward_to_controller(msg, *args)
    it "should forward ##{msg}#{args.size > 0 ? "(#{args.join(',')})" : ""} to controller" do
      if args.empty?
        @controller.should_receive(msg).with(no_args)
      else
        @controller.should_receive(msg).with(*args)
      end
      @view.send(msg, *args)
    end
  end
  
  it_should_forward_to_controller :resource_name
  it_should_forward_to_controller :resources_name
  it_should_forward_to_controller :resource
  it_should_forward_to_controller :resources
  it_should_forward_to_controller :enclosing_resource
  it_should_forward_to_controller :enclosing_resource_name
  
  it 'should not forward unknown url helper to controller' do
    @controller.stub(:resource_named_route_helper_method?).and_return(false)
    @controller.should_not_receive(:resource_foo_path)
    lambda { @view.send(:resource_foo_path) }.should raise_error(NoMethodError)
  end
  
  #pending "errors_messages_for no longer exists in rails 5"
  #pending "#error_messages_for_resource should call error_messages_for with resource_name" do
  #  @controller.should_receive(:resource_name).and_return('name')
  #  @view.should_receive(:error_messages_for).with('name')
  #  @view.error_messages_for_resource
  #end
end

describe "Helper#form_for_resource (when resource is new record)" do
  before do
    @view = ViewWithResourcesControllerHelper.new
    @controller = double('Controller')
    @specification = double('Specification')
    @specification.stub(:singleton?).and_return(false)
    @resource = double('Forum')
    @resource = double('Forum').as_null_object
    @resource.stub(:new_record?).and_return(true)
    @controller.stub(:resource).and_return(@resource)
    @controller.stub(:resource_name).and_return('forum')
    @controller.stub(:resources_path).and_return('/forums')
    @controller.stub(:resource_specification).and_return(@specification)
    @controller.stub(:resource_named_route_helper_method?).and_return(true)
    @view.controller = @controller
  end
  
  it 'should call form_for with create form options' do
    @view.should_receive(:form_for).with(@resource, {:as => 'forum', :html => {:method => :post}, :url => '/forums'})
    @view.form_for_resource{}
  end
  
  it 'when passed :url_options, they should be passed to the path generation' do
    @view.should_receive(:resources_path).with({:foo => 'bar'}).and_return('/forums?foo=bar')
    @view.should_receive(:form_for).with(@resource, {:as => 'forum', :html => {:method => :post}, :url => '/forums?foo=bar'})
    @view.form_for_resource(:url_options => {:foo => 'bar'}) {}
  end

  it 'when not passed :url_options, they should not be passed to the path generation' do
    @view.should_receive(:resources_path).with(no_args).and_return('/forums')
    @view.should_receive(:form_for).with(@resource, {:as => 'forum', :html => {:method => :post}, :url => '/forums'})
    @view.form_for_resource{}
  end
end

describe "Helper#form_for_resource (when resource is new record) and resource is singleton" do
  before do
    @view = ViewWithResourcesControllerHelper.new
    @controller = double('Controller')
    @specification = double('Specification')
    @specification.stub(:singleton?).and_return(true)
    @resource = double('Account')
    @resource = double('Account').as_null_object
    @resource.stub(:new_record?).and_return(true)
    @controller.stub(:resource).and_return(@resource)
    @controller.stub(:resource_name).and_return('account')
    @controller.stub(:resource_path).and_return('/account')
    @controller.stub(:resource_specification).and_return(@specification)
    @controller.stub(:resource_named_route_helper_method?).and_return(true)
    @view.controller = @controller
  end
  
  it 'should call form_for with create form options' do
    @view.should_receive(:form_for).with(@resource, {:as => 'account', :html => {:method => :post}, :url => '/account'})
    @view.form_for_resource{}
  end
end

describe "Helper#form_for_resource (when resource is existing record)" do
  before do
    @view = ViewWithResourcesControllerHelper.new
    @controller = double('Controller')
    @specification = double('Specification')
    @specification.stub(:singleton?).and_return(false)
    @resource = double('Forum').as_null_object
    @resource.stub(:new_record?).and_return(false)
    @resource.stub(:to_param).and_return("1")
    @controller.stub(:resource).and_return(@resource)
    @controller.stub(:resource_name).and_return('forum')
    @controller.stub(:resource_path).and_return('/forums/1')
    @controller.stub(:resource_specification).and_return(@specification)
    @controller.stub(:resource_named_route_helper_method?).and_return(true)
    @view.controller = @controller
  end
  
  it 'should call form_for with update form options' do
    @view.should_receive(:form_for).with(@resource, {:as => 'forum', :html => {:method => :put}, :url => '/forums/1'})
    @view.form_for_resource{}
  end
end

