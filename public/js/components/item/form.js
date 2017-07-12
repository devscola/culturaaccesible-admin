Class('Item.Form', {

    Extends: Component,

    initialize: function() {
        Item.Form.Super.call(this, 'formulary');
        this.alert = document.getElementById('alert');
        this.alert.addEventListener('disableFields', this.disableFields.bind(this));
        this.alert.addEventListener('uncheckRoom', this.uncheckRoom.bind(this));
        this.element.addEventListener('submitted', this.save.bind(this));
        this.element.addEventListener('roomAlert', this.showAlert.bind(this));
        this.itemForm = document.getElementById('formulary');
        this.retrieveAnExhibition();
    },

    showAlert: function() {
        this.alert.visibility = 'show';
    },

    show: function(event) {
        this.itemForm.item = event.detail;
        this.itemForm.formVisibility = 'show';
    },

    disableFields: function() {
        this.element.disableItemInput = true;
        this.emptyFields();
        this.element.parentClass = "exhibition";
    },

    emptyFields: function() {
        this.element.date = '';
        this.element.author = '';
    },

    uncheckRoom: function() {
        document.getElementsByClassName("room")[0].checked = false;
        this.element.disableItemInput = false;
        this.element.parentClass = this.itemParentClass();
    },

    itemParentClass: function(){
        return this.loadParentClass();
    },

    retrieveAnExhibition: function() {
        var parentId = this.loadParentId();
        var parentClass = this.loadParentClass();
        if (parentClass == 'room') {
            this.retrieveAnExhibitionByRoom(parentId);
            this.element.disableCheckBox = true;
        } else if (parentClass == 'scene') {
            this.retrieveAnExhibitionByItem(parentId)
        } else if (parentClass == 'exhibition') {
            var payload = { 'id': parentId };
            Bus.publish('exhibition.retrieve', payload);
            var payload = { 'id': parentId, 'ordinal': '0.0.0' }
            Bus.publish('next.number.retrieve', payload);
        }
    },

    loadExhibitionByChildren: function(children) {
      if(children.parent_class == 'room'){
        this.retrieveAnExhibitionByRoom(children.parent_id)
        return
      }
      var payload = { 'id': children.parent_id };
      Bus.publish('exhibition.retrieve', payload);
    },

    suggestNextNumber: function(nextNumber) {
        this.element.number = nextNumber;
    },

    retrieveAnExhibitionByRoom: function(parentId) {
      var payload = { 'id': parentId };
      Bus.publish('room.retrieve', payload);
    },

    retrieveAnExhibitionByItem: function(parentId) {
      var payload = { 'id': parentId };
      Bus.publish('item.retrieve', payload);
    },

    loadParentId: function() {
        var urlString = window.location.href;
        var regexp = /[exhibition|room|scene]\/(.*)\/[/item]/;
        return regexp.exec(urlString)[1];
    },

    loadParentClass: function() {
        var urlString = window.location.href;
        var regexp = /(.*)\/(.*)\/(.*)\/[/item]/;
        return regexp.exec(urlString)[2];
    },

    renderExhibition: function(exhibition) {
        this.element.exhibition = exhibition;
        this.setInitialParentAttributes(exhibition);
    },

    setInitialParentAttributes: function(exhibition) {
        this.element.parentId = this.loadParentId();
        this.element.parentClass = this.itemParentClass();
    },

    save: function(item) {
      Bus.publish('item.save', item.detail);
    },

    subscribe: function() {
        Bus.subscribe('exhibition.retrieved', this.renderExhibition.bind(this));
        Bus.subscribe('item.edit', this.show.bind(this));
        Bus.subscribe('room.retrieved', this.loadExhibitionByChildren.bind(this));
        Bus.subscribe('item.retrieved', this.loadExhibitionByChildren.bind(this));
        Bus.subscribe('next.number.retrieved', this.suggestNextNumber.bind(this));
    }
});
