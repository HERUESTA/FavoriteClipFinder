// app/javascript/controllers/game_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clearButton"]

  submit(event) {
    const searchQuery = this.inputTarget.value.trim();
    
    if (searchQuery === "") {
      // 入力が空の場合は、フォームの送信をキャンセル
      event.preventDefault();
      console.log("検索クエリが空のため、検索をキャンセルしました");
    }
  }

  // 入力があったときにクリアボタンを表示する
  connect() {
    this.inputTarget.addEventListener("input", () => {
      if (this.inputTarget.value.trim() === "") {
        this.clearButtonTarget.classList.add("hidden");
      } else {
        this.clearButtonTarget.classList.remove("hidden");
      }
    });

    // クリアボタンを押したときに検索ボックスをクリア
    this.clearButtonTarget.addEventListener("click", () => {
      this.inputTarget.value = "";
      this.clearButtonTarget.classList.add("hidden");
    });
  }
}
