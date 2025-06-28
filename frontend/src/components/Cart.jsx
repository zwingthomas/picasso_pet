import React, {useState} from "react";
import api from "../services/api";

export default function Cart({cart, onClear}) {
  const [loading, setLoading] = useState(false);

  const handleCheckout = async () => {
    setLoading(true);
    const order = {
      user_email: prompt("Enter your email"),
      items: cart.map((item) => ({
        product_id: item.product.id,
        quantity: 1,
        pet_image_id: item.pet.id,
      })),
    };
    const {url} = await api.createCheckout(order);
    window.location.href = url;
  };

  return (
    <div className="cart">
      <h2>Your Cart</h2>
      {cart.map((item, i) => (
        <div key={i}>{item.product.name}</div>
      ))}
      <button onClick={handleCheckout} disabled={loading}>
        Pay with Stripe
      </button>
      <button onClick={onClear}>Clear</button>
    </div>
  );
}
