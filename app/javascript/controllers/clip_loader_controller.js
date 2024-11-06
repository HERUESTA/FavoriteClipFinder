// app/javascript/controllers/loading_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["loading", "clips"]

  connect() {
    // 初期状態でロードアイコンを表示し、クリップを非表示にする
    this.showLoading();
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden");
    this.clipsTarget.style.opacity = "0";
  }

  hideLoading() {
    // Turboフレームのロードが完了したら、ロードアイコンを非表示にし、クリップを表示する
    this.loadingTarget.classList.add("hidden");
    this.clipsTarget.style.opacity = "1";
  }
}
