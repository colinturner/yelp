require 'rails_helper'

feature 'restaurants' do

  before do
    visit('/')
    click_link('Sign up')
    fill_in('Email', with: "jack@jack.jack")
    fill_in('Password', with: "jackjack")
    fill_in('Password confirmation', with: "jackjack")
    click_button('Sign up')
  end

  context 'no restaurants have been added' do
    scenario 'should display a prompt to add a restaurant' do
      visit '/restaurants'
      expect(page).to have_content 'No restaurant yet'
      expect(page).to have_link 'Add a restaurant'
    end
  end

  context 'restaurants have been added' do
    before do
      Restaurant.create(name: 'KFC', description: 'Chunky charred chicken')
    end

    scenario 'display restaurants' do
      visit '/restaurants'
      expect(page).to have_content('KFC')
      expect(page).to have_content('Chunky charred chicken')
      expect(page).not_to have_content('No restaurants yet')
    end
  end

  context 'creating restaurants' do
    scenario 'prompts user to fill out a form, then displays a new restaurant' do
      visit '/restaurants'
      click_link 'Add a restaurant'
      fill_in 'Name', with: 'KFC'
      click_button 'Save Restaurant'
      expect(page).to have_content 'KFC'
      expect(current_path).to eq '/restaurants'
    end

    context "an invalid restaurant" do
      scenario "does not let you submit a name that is too short" do
        visit '/restaurants'
        click_link "Add a restaurant"
        fill_in 'Name', with: 'kf'
        click_button 'Save Restaurant'
        expect(page).not_to have_css 'h2', text: 'kf'
        expect(page).to have_content 'error'
      end
    end
  end

  context 'editing restaurants' do
    before { Restaurant.create name: 'KFC', description: 'Deep fried goodness', id: 1 }
    scenario 'let a user edit a restaurant' do
      visit '/restaurants'
      click_link 'Edit KFC'
      fill_in 'Name', with: 'Kentucky Fried Chicken'
      fill_in 'Description', with: 'Deep fried goodness'
      click_button 'Update Restaurant'
      expect(page).to have_content 'Kentucky Fried Chicken'
      expect(page).to have_content 'Deep fried goodness'
      expect(current_path).to eq '/restaurants'
    end
  end

  context 'deleting restaurants' do

    before { Restaurant.create name:'KFC', description: 'Deep fried goodness' }

    scenario 'removes a restaurant when a user clicks a delete link' do
      visit '/restaurants'
      click_link 'Delete KFC'
      expect(page).not_to have_content 'KFC'
      expect(page).to have_content 'Restaurant deleted successfully'
    end

    scenario "user tries to delete someone else's restaurant" do
      visit '/'
      # First user adds a restaurant
      click_link "Add a restaurant"
      fill_in 'Name', with: 'Subway'
      fill_in 'Description', with: 'Sandwiches and cookies'
      click_button 'Save Restaurant'
      click_link 'Sign out'
      # Second user signs up
      click_link 'Sign up'
      fill_in 'Email', with: "colin@colin.colin"
      fill_in 'Password', with: "colincolin"
      fill_in 'Password confirmation', with: "colincolin"
      click_link 'Sign up'
      expect(page).to have_content 'Sandwiches and cookies'
      # Second user tries to delete first user's restaurant
      click_link 'Delete Subway'
      expect(page).to have_content "You can only delete restaurants you've added yourself"

    end
  end

  context 'user not signed in' do
    scenario 'tries to create a restaurant' do
      visit '/'
      click_link 'Sign out'
      click_link 'Add a restaurant'
      expect(current_path).to eq '/users/sign_in'
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end
end
