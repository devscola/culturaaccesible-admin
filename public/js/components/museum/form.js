Class('Museum.Form', {

    Extends: Component,

    contactFields: {phone: [], email: [], web: []},

    priceFields: {freeEntrance: [], general: [], reduced: []},

    storage: {MON: [], TUE: [], WED: [], THU: [], FRI: [], SAT: [], SUN: []},

    initialize: function() {
        Museum.Form.Super.call(this, 'formulary');
        this.newButton = document.getElementById('newMuseum');
        this.saveButton = document.getElementById('action');
        this.result = document.getElementById('result');

        this.infoForm = document.getElementById('info');
        this.locationForm = document.getElementById('location');
        this.contactForm = document.getElementById('contact');
        this.priceForm = document.getElementById('price');
        this.scheduleForm = document.getElementById('schedule');

        this.scheduleForm.scheduleData = this.storage;
        this.contactForm.contactData = this.contactFields;
        this.priceForm.priceData = this.priceFields;

        this.addListeners();
        this.hide();
    },

    hide: function() {
        this.element.style.display = 'none';
    },

    show: function() {
        this.element.style.display = 'block';
    },

    addListeners: function() {
        this.newButton.addEventListener('click', this.show.bind(this));
        this.element.addEventListener('submit', this.collectData.bind(this));

        this.element.addEventListener('notEnoughInfo', this.revokeInfo.bind(this));
        this.element.addEventListener('notEnoughLocation', this.revokeLocation.bind(this));
        this.element.addEventListener('enoughInfo', this.storeInfo.bind(this));
        this.element.addEventListener('enoughLocation', this.storeLocation.bind(this));
    },

    collectData: function() {
        this.museumData = {};
        Object.assign(
            this.museumData,
            {info: this.infoForm.infoData},
            {location: this.locationForm.locationData},
            {contact: this.contactForm.contactData},
            {price: this.priceForm.priceData},
            {schedule: this.scheduleForm.scheduleData}
        );
        Bus.publish('museum.save', this.museumData);
        this.showsInfo();
    },

    showsInfo: function(museumData) {
        this.hide();
        this.result.museumData = museumData;
        this.result.visibility = 'show';
    },

    revokeInfo: function() {
        this.enoughInfo = false;
        this.verifyEnoughContent();
    },

    revokeLocation: function() {
        this.enoughLocation = false;
        this.verifyEnoughContent();
    },

    storeInfo: function(event) {
        this.infoValues = event.detail;
        this.enoughInfo = true;
        this.verifyEnoughContent();
    },

    storeLocation: function(event) {
        this.locationValues = event.detail;
        this.enoughLocation = true;
        this.verifyEnoughContent();
    },

    verifyEnoughContent: function() {
        if (this.enoughInfo && this.enoughLocation) {
            this.allowSubmit();
        } else {
            this.disallowSubmit();
        }
    },

    allowSubmit: function() {
        this.saveButton.active = true;
    },

    disallowSubmit: function() {
        this.saveButton.active = false;
    },

    subscribe: function() {
        Bus.subscribe('museum.saved', this.showsInfo.bind(this));
    }

});
