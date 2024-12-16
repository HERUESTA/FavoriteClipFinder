import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  disable(event) {

    const link = event.currentTarget;

    // クリックを無効化
    link.style.pointerEvents = "none"; // クリックイベントを無効化
    link.classList.add("opacity-50"); // 視覚的に無効化状態を示す (任意)

    // 1秒後にクリックを再度有効化
    setTimeout(() => {
      link.style.pointerEvents = "auto"; // クリックイベントを有効化
      link.classList.remove("opacity-50"); // 無効化状態のスタイルを戻す (任意)
    }, 2000);
  }
}