require 'spec_helper_tdd'
require_relative '../../system/exhibitions/service'

describe Exhibitions::Service do
  before(:each) do
    Exhibitions::Repository.flush
  end

  it 'retrieves an exhibition with date creation' do
    name = 'some name'
    location = 'some location'
    result = add_exhibition(name, location)

    exhibition = Exhibitions::Service.retrieve(result[:id])

    expect(exhibition[:name]).to eq(name)
    expect(exhibition.include?(:creation_date)).to be true
  end

  it 'retrieves all exhibitions' do
    name = 'some name'
    location = 'some location'
    add_exhibition(name, location)

    result = Exhibitions::Service.list

    expect(result.any?).to be true
  end

  it 'defense of nullable parameters' do
    name = 'some name'
    location = nil
    result = add_exhibition(name, location)

    exhibition = Exhibitions::Service.retrieve(result[:id])

    expect(exhibition[:name]).to eq(name)
    expect(exhibition[:location]).to eq('')
  end

  it 'deletes an exhibition' do
    name = 'some name'
    location = 'some location'
    exhibition = add_exhibition(name, location)

    exhibition = Exhibitions::Service.delete(exhibition[:id])

    expect(exhibition[:deleted]).to be true
  end

  def add_exhibition(name, location)
    exhibition = { 'name' => name, 'location' => location }
    Exhibitions::Service.store(exhibition)
  end

  def add_scene(name, number='', parent_id)
    scene = {'id' => '', 'name' => name, 'number' => number, 'parent_id' => parent_id, 'exhibition_id' => parent_id, 'parent_class' => 'exhibition',  'type' => 'scene' }
    Items::Service.store_scene(scene)
  end

  def add_scene_into_room(name, number, exhibition_id, room_id)
    scene = {'id' => '', 'name' => name, 'number' => number, 'parent_id' => room_id, 'exhibition_id' => exhibition_id, 'parent_class' => 'room',  'type' => 'scene' }
    Items::Service.store_scene(scene)
  end

  def add_room(name, number, exhibition_id)
    room = {'id' => '', 'name' => name, 'number' => number, 'parent_id' => exhibition_id, 'exhibition_id' => exhibition_id, 'parent_class' => 'exhibition', 'room' => true,  'type' => 'room' }
    Items::Service.store_room(room)
  end
end
