require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::View, 'Variables' do
  class NeedyView < Garterbelt::View
    requires :x, :y 
  end

  class SelectiveView < Garterbelt::View 
    requires_only :x, :y
  end   
  
  class ExtraNeedy < NeedyView  
    requires :z
  end 
  
  class LessNeedy < Garterbelt::View 
    requires :x => 'x', :y => 'y'
  end 
  
  describe 'class level requirements' do
    it 'the class should store a list of required variables' do 
      NeedyView.required.should == [:x, :y]
      SelectiveView.required.should == [:x, :y] 
    end  
  
    it 'should add to the required set of variable of the subclass' do
      ExtraNeedy.required.should == [:x, :y, :z] 
    end  
  
    describe 'default values' do
      it '#requires and #requires_only should allow the last argument to be a hash with default values' do 
        lambda{ LessNeedy.new }.should_not raise_error
      end
      
      it 'stores the default values on the class' do
        LessNeedy.default_variables.should == {:y => 'y', :x => 'x'}
        ExtraNeedy.default_variables.should == {}
      end
      
      it 'inherits default values from superclass' do
        class SecondGenLessNeedy < LessNeedy
        end
        
        SecondGenLessNeedy.default_variables.should == {:y => 'y', :x => 'x'}
      end
      
      it 'adds to default values of the superclass' do
        class SecondGenLessNeedy < LessNeedy
          requires :z => 'z'
        end
        
        SecondGenLessNeedy.default_variables.should == {:x => 'x', :y => 'y', :z => 'z'}
      end
      
      it 'overwrites superclass defaults' do
        class SecondGenLessNeedy < LessNeedy
          requires :z => 'z'
        end
        
        class ThirdGen < SecondGenLessNeedy
          requires :z => 'x'
        end
        
        ThirdGen.default_variables.should == {:x => 'x', :y => 'y', :z => 'x'}
      end
    end
    
    it 'aliases #requires to #needs' do
      class AltlyNeedy < NeedyView  
        needs :z
      end 
      AltlyNeedy.required.should == [:x, :y, :z]
    end
    
    it 'aliases #requires_only to #needs_only' do
      class AltlyView < Garterbelt::View 
        needs_only :x, :y
      end
      AltlyView.required.should == [:x, :y]
    end
    
    describe 'accessor' do
      describe 'without default' do
        it 'builds readers for the required variables' do
          NeedyView.instance_methods.should include 'x'
          NeedyView.instance_methods.should include 'y'
        end
      
        it 'builds writers for the required variables' do
          NeedyView.instance_methods.should include 'x='
          NeedyView.instance_methods.should include 'y='
        end
      end
      
      describe 'with defaults' do
        it 'makes readers' do
          LessNeedy.instance_methods.should include 'x'
          LessNeedy.instance_methods.should include 'y'
        end
        
        it 'makes writers' do
          LessNeedy.instance_methods.should include 'x='
          LessNeedy.instance_methods.should include 'y='
        end
      end

      describe 'allowed accessors' do
        it 'raises on compile if the required variables map to existing view methods' do
          lambda {
            class Failer < Garterbelt::View
              requires :p
            end
          }.should raise_error(ArgumentError, ":p cannot be a required variable because it maps to an existing method")
        end
      
        it 'does not raise an error when overriding Object instance methods' do
          lambda {
            class Doer < Garterbelt::View
              requires :tap
            end
          }.should_not raise_error
        end
      end
    end    
  end
  
  describe 'initialization' do
    describe 'without defaults' do
      it 'sets the accessors with the values provided' do
        view = NeedyView.new :x => 'foo', :y => 'bar'
        view.x.should == 'foo'
        view.y.should == 'bar'
      end
      
      it 'raises an error when values are not provided' do
        lambda { NeedyView.new :x => 'x' }.should raise_error(ArgumentError, "[:y] required as an initialization option")
      end
    end
    
    describe 'with defaults' do
      it 'sets accessors with default values' do
        view = LessNeedy.new
        view.x.should == 'x'
        view.y.should == 'y'
      end
    
      it 'sets accessors with custom value' do
        view = LessNeedy.new(:x => 'foo', :y => 'bar')
        view.x.should == 'foo'
        view.y.should == 'bar'
      end
    end
    
    it 'builds class level accessors when it receives additional parameters' do
      class ExtraNeed < Garterbelt::View
        requires :x, :y
      end
      
      view = ExtraNeed.new :x => 'foo', :y => 'bar', :z => 'zardoz'
      view.should respond_to :z
    end
    
    it 'raises an error when selective and it receives additional parameters' do
      lambda { SelectiveView.new(:x => 'x', :y => 'y', :z => 'zardoz') }.should raise_error(
        ArgumentError, "Allowed initalization options are only [:x, :y]"
      )
    end
  end
end