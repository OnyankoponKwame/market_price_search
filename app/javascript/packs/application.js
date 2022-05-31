// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "bootstrap";
import "../stylesheets/application.scss";
import { createApp } from 'vue'
import App from '../App.vue'

window.bootstrap = require("bootstrap")

document.addEventListener("DOMContentLoaded", () => {
  const app = createApp(App);
  if(document.getElementById("vue-app") != null){
    app.mount("#vue-app")
  }
});

Rails.start()
ActiveStorage.start()
