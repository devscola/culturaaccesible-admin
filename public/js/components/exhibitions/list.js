Class('Exhibitions.List', {

    Extends: Component,

    initialize: function() {
        Exhibitions.List.Super.call(this, 'listing');
        this.element.exhibitionsList = [];
        this.retrieve();
    },

    render: function(exhibitions) {
        this.element.exhibitionsList = [];
        exhibitions.forEach(exhibition => {
            var payload = {"id": exhibition.id};
            Bus.publish('exhibition.for.list.retrieve', payload);
        })
    },

    addExhibitionChildren: function(exhibition){
        this.element.exhibitionsList.push(exhibition);
        this.polymerWorkAround();
    },

    polymerWorkAround: function(){
        var temporary = this.element.exhibitionsList;
        this.element.exhibitionsList = [];
        this.element.exhibitionsList = temporary;
    },

    refresh: function() {
        Bus.publish('exhibitions.list.retrieve');
    },

    retrieve: function() {
        Bus.publish('exhibitions.list.retrieve');
    },

    subscribe: function() {
        Bus.subscribe('exhibitions.list.retrieved', this.render.bind(this));
        Bus.subscribe('exhibition.for.list.retrieved', this.addExhibitionChildren.bind(this));
        Bus.subscribe('exhibition.saved', this.refresh.bind(this));
    }
});
