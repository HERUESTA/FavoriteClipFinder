import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iframe", "container", "loading"]

  connect() {
    console.log("Stimulus controller connected");
    this.loadedCount = 0;
    this.totalIframes = this.iframeTargets.length;

    console.log("Total iframes: ", this.totalIframes);

    // iframeがロードされたときのイベントリスナーを追加
    this.iframeTargets.forEach(iframe => {
      iframe.addEventListener('load', () => {
        this.handleIframeLoad();
      });
    });
  }

  handleIframeLoad() {
    this.loadedCount += 1;
    console.log("Loaded iframe count: ", this.loadedCount);

    // すべてのiframeがロードされた場合に実行
    if (this.loadedCount === this.totalIframes) {
      this.showClips();
    }
  }

  showClips() {
    // ローディングマークを消して、コンテナを表示
    this.loadingTarget.style.display = "none";
    this.containerTarget.style.opacity = "1";
    console.log("All iframes loaded, showing container");
  }
}