import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]

  connect() {
    this.frameTarget.addEventListener("load", () => {
      this.showFrame();
    });
  }

  showFrame() {
    // iframeを表示する
    this.frameTarget.style.display = "block";
  }
}
