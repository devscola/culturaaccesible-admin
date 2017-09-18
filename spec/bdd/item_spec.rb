require 'spec_helper_bdd'
require_relative 'test_support/fixture_museum'
require_relative 'test_support/museum'
require_relative 'test_support/item'
require_relative 'test_support/fixture_item'
require_relative 'test_support/exhibitions'
require_relative 'test_support/fixture_exhibitions'
require_relative 'test_support/room_info'
require_relative 'test_support/scene_info'

feature 'Item' do
  feature 'creating an item' do
    before :all do
      Fixture::Exhibitions.pristine.complete_scenario
    end

    scenario 'date must be four characters long' do
      current = get_an_item_form
      current.fill('date',Fixture::Item::ERROR_LENGTH_DATE)

      expect(current.type_max_four_characters).to be true
    end

    scenario 'requires name' do
      current = get_an_item_form
      current.fill('name',Fixture::Item::ARTWORK)

      expect(current.submit_disabled?).to be false
    end

    scenario 'shows data inserted' do
      current = get_an_item_form
      current.fill('name',Fixture::Item::ARTWORK)
      current.submit

      expect(current.content?(Fixture::Item::VISIBLE_ARTWORK)).to be true
    end

    def get_an_item_form
      Fixture::Item.get_an_item_form
    end
  end

  scenario 'displays an alert when author or date are filled and room checkbox is typed' do
    current = Fixture::Item.shows_room_alert

    expect(current.alert_displayed?).to be true
  end

  scenario 'disallows to fill author and date when alert is accepted' do
    current = Fixture::Item.shows_room_alert

    current.accept_alert

    expect(current.room_checked?).to be true
    expect(current.input_blank?('author')).to be true
    expect(current.input_blank?('date')).to be true
    expect(current.input_disabled?('author')).to be true
    expect(current.input_disabled?('date')).to be true
  end

  scenario 'allows to fill author and date when alert is canceled' do
    current = Fixture::Item.shows_room_alert

    current.cancel_alert

    expect(current.room_checked?).to be false
    expect(current.input_disabled?('author')).to be false
    expect(current.input_disabled?('date')).to be false
  end

  scenario 'disallows to fill author and date' do
    current = Fixture::Item.from_exhibition_to_new_item

    expect(current.input_disabled?('author')).to be false
    expect(current.input_disabled?('date')).to be false

    current.check_room

    expect(current.input_disabled?('author')).to be true
    expect(current.input_disabled?('date')).to be true
  end

  scenario 'valid for submit if item number is validated' do
    current = Fixture::Item.from_exhibition_to_new_item

    current.fill('name',Fixture::Item::ARTWORK)
    current.fill('number',Fixture::Item::FIRST_NUMBER)

    current.submit

    current = Page::Exhibitions.new
    current.click_plus_button

    current = Page::Item.new

    current.fill('name',Fixture::Item::ARTWORK)
    current.fill('number',Fixture::Item::SECOND_NUMBER)

    expect(current.submit_disabled?).to be false
  end

  scenario 'invalid for submit if item number is not validated' do
    current = Fixture::Item.from_exhibition_to_new_item

    current.fill('name',Fixture::Item::ARTWORK)
    current.fill('number',Fixture::Item::FIRST_NUMBER)

    current.submit

    current = Page::Exhibitions.new
    current.click_plus_button

    current = Page::Item.new

    current.fill('name',Fixture::Item::ARTWORK)
    current.fill('number',Fixture::Item::REPEATED_NUMBER)

    expect(current.submit_disabled?).to be true
  end

  scenario 'suggests next first order number' do
    current = Fixture::Item.from_exhibition_to_new_item

    current.fill('name',Fixture::Item::ARTWORK)
    result = current.find_suggested_number

    expect(result).to eq('1-0-0')
  end

  scenario 'suggests next second order number' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved('1-0-0')
    current = Page::Exhibitions.new
    current.toggle_list
    current.click_room_plus_button
    current = Page::Item.new

    current.fill('name',Fixture::Item::OTHER_ARTWORK)
    result = current.find_suggested_number

    expect(result).to eq('1-1-0')
  end

  scenario 'save room when submit' do
    current = Fixture::Item.from_exhibition_to_new_item

    current.check_room
    current.fill('name',Fixture::Item::ARTWORK)
    current.fill('number',Fixture::Item::FIRST_NUMBER)

    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_ARTWORK)).to be true
  end

  scenario 'add item to a room has disabled checkbox' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.room_saved

    current = Page::Exhibitions.new

    current.toggle_list

    current.click_room_plus_button

    current = Page::Item.new

    expect(current.room_check_disabled?).to be true
  end


  scenario 'lock checkbox when room is edited' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_room_info

    current = Page::RoomInfo.new
    current.click_edit

    current = Page::Item.new

    expect(current.room_check_disabled?).to be true
  end

  scenario 'lock checkbox when scene is edited' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.item_saved
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_scene_info

    current = Page::SceneInfo.new
    current.click_edit
    current = Page::Item.new

    expect(current.room_check_disabled?).to be true
  end

  scenario 'fix add room when item fields are filled' do
    Fixture::Item.from_exhibition_to_new_item

    current = Fixture::Item.item_filled

    current.check_room
    current.accept_alert

    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_ARTWORK)).to be true
    expect(current.content?(Fixture::Item::VISIBLE_AUTHOR)).to be false
  end

  scenario 'add item to a room' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.room_saved

    Fixture::Item.item_saved_in_room

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.room_has_children?).to be true
  end

  scenario 'shows room info when room name is clicked' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.room_saved

    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_room_info

    current = Page::RoomInfo.new

    expect(current.content?(Fixture::Item::INFO_FIRST_NUMBER)).to be true
  end

  scenario 'shows scene info when scene name is clicked' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.item_saved

    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_scene_info

    current = Page::SceneInfo.new

    expect(current.content?(Fixture::Item::INFO_SECOND_NUMBER)).to be true
  end

  scenario 'shows subscene info when subscene name is clicked' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.item_saved

    Fixture::Item.item_saved_in_item

    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_subscene_info

    current = Page::SceneInfo.new

    expect(current.content?(Fixture::Item::INFO_THIRD_NUMBER)).to be true
  end

  scenario 'shows subscene info when subscene name from room > scene > subscene is clicked' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.room_saved

    Fixture::Item.item_saved_in_room

    Fixture::Item.item_saved_in_item

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.scene_in_room_has_children?).to be true

    current.go_to_subscene_info_into_room

    current = Page::SceneInfo.new


    expect(current.content?(Fixture::Item::INFO_THIRD_NUMBER)).to be true
  end

  scenario 'shows number of items in exhibition list' do
    room_number = '1-0-0'
    scene_number = '1-1-0'
    subscene_number = '1-1-1'
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved(room_number)
    Fixture::Item.item_saved_in_room(scene_number)
    Fixture::Item.item_saved_in_item(subscene_number)

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.content?(room_number)).to be true
    expect(current.content?(scene_number)).to be true
    expect(current.content?(subscene_number)).to be true
  end

  scenario 'add item to an item' do
    Fixture::Item.from_exhibition_to_new_item

    Fixture::Item.item_saved

    Fixture::Item.item_saved_in_item

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.scene_has_children?).to be true
  end

  scenario 'room info is editable when edit button is clicked' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved

    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_room_info

    current = Page::RoomInfo.new
    current.click_edit

    current = Page::Item.new

    expect(current.input_value?('name')).to eq Fixture::Item::ARTWORK
    expect(current.content?(Fixture::Item::SAVE_BUTTON)).to be true

    current.fill('name',Fixture::Item::OTHER_ARTWORK)
    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_OTHER_ARTWORK)).to be true

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.room_info?(Fixture::Item::OTHER_ARTWORK)).to be true
  end

  scenario 'scene info is editable when edit button is clicked' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.item_saved

    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_scene_info
    current = Page::SceneInfo.new
    current.click_edit
    current = Page::Item.new

    expect(current.input_value?('name')).to eq Fixture::Item::ARTWORK
    expect(current.input_value?('author')).to eq Fixture::Item::AUTHOR
    expect(current.input_value?('date')).to eq Fixture::Item::DATE
    expect(current.content?(Fixture::Item::SAVE_BUTTON)).to be true

    current.fill('name',Fixture::Item::OTHER_ARTWORK)
    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_OTHER_ARTWORK)).to be true

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.scene_info?(Fixture::Item::OTHER_ARTWORK)).to be true
  end

  scenario 'scene info inside a room is editable when edit button is clicked' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved
    Fixture::Item.item_saved_in_room
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_scene_inside_room_info

    current = Page::SceneInfo.new
    current.click_edit
    current = Page::Item.new

    expect(current.input_value?('name')).to eq Fixture::Item::OTHER_ARTWORK
    expect(current.content?(Fixture::Item::SAVE_BUTTON)).to be true

    current.fill('name',Fixture::Item::ARTWORK)
    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_ARTWORK)).to be true

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.scene_inside_room_info?(Fixture::Item::ARTWORK)).to be true
  end

  scenario 'subscene info inside a scene is editable when edit button is clicked' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.item_saved
    Fixture::Item.item_saved_in_item
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_subscene_info

    current = Page::SceneInfo.new
    current.click_edit
    current = Page::Item.new

    expect(current.input_value?('name')).to eq Fixture::Item::OTHER_ARTWORK
    expect(current.content?(Fixture::Item::SAVE_BUTTON)).to be true

    current.fill('name',Fixture::Item::ARTWORK)
    current.submit

    expect(current.content?(Fixture::Item::VISIBLE_ARTWORK)).to be true

    current = Page::Exhibitions.new
    current.toggle_list

    expect(current.subscene_info?(Fixture::Item::ARTWORK)).to be true
  end

  scenario 'returns right ordinal number in each level', :wip do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved_with_automatic_number
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_room_info
    current = Page::RoomInfo.new

    expect(current.content?('1-0-0')).to be true

    Fixture::Item.scene_saved_in_room_with_automatic_number
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_scene_inside_room_info
    current = Page::SceneInfo.new

    expect(current.content?('1-1-0')).to be true

    Fixture::Item.subscene_saved_in_scene_with_automatic_number
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_subscene_info_into_room
    current = Page::SceneInfo.new

    expect(current.content?('1-1-1')).to be true

    current = Page::Exhibitions.new
    current.click_plus_button
    current = Fixture::Item.scene_saved_with_automatic_number
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_scene_info
    current = Page::SceneInfo.new

    expect(current.content?('2-0-0')).to be true

    Fixture::Item.subscene_saved_in_second_scene_with_automatic_number
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_last_subscene_info
    current = Page::SceneInfo.new

    expect(current.content?('2-1-0')).to be true
  end

  scenario 'avoid create rooms in subscenes' do
    Fixture::Item.from_exhibition_to_new_item
    Fixture::Item.room_saved_with_automatic_number
    Fixture::Item.scene_saved_in_room_with_automatic_number
    current = Page::Exhibitions.new

    current.toggle_list

    current.click_item_plus_button

    current = Page::Item.new

    expect(current.room_check_disabled?).to be true
  end

  scenario 'shows sidebar in all room pages' do
    current_exhibition = Page::Exhibitions.new
    Fixture::Item.from_exhibition_to_new_item
    expect(current_exhibition.has_toggle?).to be true

    Fixture::Item.room_saved
    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_room_info
    Page::RoomInfo.new
    expect(current_exhibition.has_toggle?).to be true

    current = Page::RoomInfo.new
    current.click_edit
    Page::Item.new
    expect(current_exhibition.has_toggle?).to be true
  end

  scenario 'shows sidebar in all scene pages' do
    current_exhibition = Page::Exhibitions.new
    Fixture::Item.from_exhibition_to_new_item
    expect(current_exhibition.has_toggle?).to be true

    Fixture::Item.item_saved
    current = Page::Exhibitions.new
    current.toggle_list

    current.go_to_scene_info
    Page::SceneInfo.new
    expect(current_exhibition.has_toggle?).to be true

    current = Page::SceneInfo.new
    current.click_edit
    Page::Item.new
    expect(current_exhibition.has_toggle?).to be true
  end

  scenario 'fix exhibitions edition when it has items' do
    Fixture::Exhibitions.pristine.complete_scenario

    current = Page::Exhibitions.new
    current.go_to_exhibition_info(Fixture::Exhibitions::NAME)
    current.click_edit
    current.fill('name', Fixture::Exhibitions::OTHER_NAME)
    current.select_museum(Fixture::Museum::FIRST_MUSEUM)
    current.save
    current = Page::Exhibitions.new

    expect(current.has_toggle?).to be true

    current.last_toggle_list()

    expect(current.exhibition_name(Fixture::Exhibitions::OTHER_NAME)).to eq(Fixture::Exhibitions::OTHER_NAME)
    expect(current.content?('room')).to be true
  end

  scenario 'displays exhibition languages info in edit view info' do
    Fixture::Exhibitions.pristine.complete_scenario
    Page::Exhibitions.new

    Fixture::Item.from_exhibition_to_new_item
    current = Page::Item.new
    current.fill_form_with_languages
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_room_info

    expect(current.content?('nombre de room')).to be true
    expect(current.content?('descripció de room')).to be true
    expect(current.content?('https://s3.amazonaws.com/pruebas-cova/more3minutes.mp4')).to be true
  end

  scenario 'displays exhibition languages info in edited item view info' do
    Fixture::Exhibitions.pristine.complete_scenario
    Page::Exhibitions.new

    Fixture::Item.from_exhibition_to_new_item
    current = Page::Item.new
    current.fill_form_with_languages
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_room_info
    current = Page::RoomInfo.new
    current.click_edit
    current = Page::Item.new
    current.fill('video-cat', 'https://s3.amazonaws.com/pruebas-cova/3minutes.mp4')
    current.submit
    current = Page::Exhibitions.new
    current.toggle_list
    current.go_to_room_info
    current = Page::RoomInfo.new

    expect(current.find_content('.name-es')).to eq 'Name: nombre de room'
    expect(current.find_content('.description-cat')).to eq 'Description: descripció de room'
    expect(current.find_content('.video-cat')).to eq 'Video: https://s3.amazonaws.com/pruebas-cova/3minutes.mp4'
  end
end
