// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.minicolors
//= require jquery.minicolors.simple_form
//= require semantic-ui
//= require dropzone
//= require_tree .

$(document).ready(function () {

    $("#new_upload").dropzone({
        parallelUploads: 1,
        paramName: "picture[image]",
        acceptedFiles: '.jpg, .jpeg',

        addRemoveLinks: true,
        success: function (file) {
            // grap the id of the uploaded file we set earlier
            var id = $(file.previewTemplate).find('.dz-remove').attr('id');
            var url = '/pictures/' + id;
            window.location.href = '/pictures/second';
        }

    });
});