import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "SigninChannel",
        code: this.data.get("code"),
      },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this),
      }
    );
  }

  _connected() {}

  _disconnected() {}

  _received(data) {
    fetch(data.url, {
      method: "POST",
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: data['email'], code: data['code'] })
    }).then(_ => {
      window.location.reload();
    });
  }
}
