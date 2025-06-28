import React from "react";

export default function ProductList({
  products,
  croppedFile,
  onAdd,
  onCheckout,
}) {
  return (
    <div className="product-list">
      {products.map((prod) => (
        <div key={prod.id} className="product-card">
          <img
            src={
              croppedFile.processed_key
                ? /* GCS URL */ croppedFile.processed_key
                : ""
            }
            alt="Preview"
          />
          <h2>{prod.name}</h2>
          <p>${(prod.price_cents / 100).toFixed(2)}</p>
          <button onClick={() => onAdd({product: prod, pet: croppedFile})}>
            Add to Cart
          </button>
        </div>
      ))}
      <button onClick={onCheckout}>Go to Checkout</button>
    </div>
  );
}
