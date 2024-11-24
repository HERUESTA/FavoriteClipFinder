import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("opacity-0")
      setTimeout(() => {
        this.element.remove()
      }, 500) // フェードアウトのアニメーション時間と一致させる
    }, 2000) // 2秒後にフェードアウト
  }
}