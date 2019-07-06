require 'rails_helper'

RSpec.describe GramsController, type: :controller do

  describe "grams#destroy action" do
    it "should not let a user destroy other users grams" do
      gram = FactoryBot.create(:gram)
      user = FactoryBot.create(:user)
      sign_in user

      delete :destroy, params: {id: gram.id}
      expect(response).to have_http_status(:forbidden)
    end

    it "should only allow signed in users to destroy a gram" do
      gram = FactoryBot.create(:gram)
      delete :destroy, params: {id: gram.id}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow a user to destroy grams" do
      gram = FactoryBot.create(:gram)
      sign_in gram.user
      delete :destroy, params: {id: gram.id}
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end

    it "should return a 404 error if the gram cant be found" do
      user = FactoryBot.create(:user)
      sign_in user
      delete :destroy, params: {id: 'false'}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "gram#update action" do
    it "should not let a user update other users grams" do
      gram = FactoryBot.create(:gram)
      user = FactoryBot.create(:user)
      sign_in user

      patch :update, params: {id: gram.id, gram: {message: 'changed'}}
      expect(response).to have_http_status(:forbidden)
    end

    it "should only allow signed in users to update a gram" do
      gram = FactoryBot.create(:gram)
      patch :update, params: {id: gram.id, gram: {message: 'changed'}}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      gram = FactoryBot.create(:gram, message: "initial value")
      sign_in gram.user
      patch :update, params: {id: gram.id, gram: {message: 'changed'}}
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "changed"
    end

    it "should return a 404 error if the gram cant be found" do
      user = FactoryBot.create(:user)
      sign_in user
      patch :update, params: {id: 'false', gram: {message: 'changed'}}
      expect(response).to have_http_status(:not_found)
    end 

    it "should render the edit form with an http status of unprocessable_entity" do
      gram = FactoryBot.create(:gram, message: 'initial value')
      sign_in gram.user
      patch :update, params: {id: gram.id, gram: {message: ''}}
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq "initial value"
    end
  end
  describe "grams#edit action" do
    it "should not let a user edit other users grams" do
      gram = FactoryBot.create(:gram)
      user = FactoryBot.create(:user)
      sign_in user

      get :edit, params: {id: gram.id}
      expect(response).to have_http_status(:forbidden)
    end

    it "should only allow signed in users to edit a gram" do
      gram = FactoryBot.create(:gram)
      get :edit, params: {id: gram.id}
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryBot.create(:gram)
      sign_in gram.user
      get :edit, params: { id: gram.id}
      expect(response).to have_http_status(:success)
    end

    it "should return 404 error if gram is not found" do
      user = FactoryBot.create(:user)
      sign_in user
      get :edit, params: {id: 'false'}
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do 
      gram = FactoryBot.create(:gram)
      get :show, params: {id: gram.id}
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, params: {id: 'false'}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should successfully show the new form" do
      user = FactoryBot.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do 
      post :create, params: { grams: {message: 'test'} }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in database" do
      user = FactoryBot.create(:user)
      sign_in user
      post :create, params: 
        {gram: {
          message: 'test',
          picture: fixture_file_upload("/picture.png", 'image/png')
        }
      }

      expect(response).to redirect_to root_path
      gram = Gram.last
      expect(gram.message).to eq('test')
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
     user = FactoryBot.create(:user)
     sign_in user
     gram_count = Gram.count
     post :create, params: {gram: {message: ' '} }
     expect(response).to have_http_status(:unprocessable_entity)
     expect(gram_count).to eq Gram.count
    end
  end
end
