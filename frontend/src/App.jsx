import React, {useState, useEffect} from "react";
import Cropper from "./components/Cropper";
import ProductList from "./components/ProductList";
import Cart from "./components/Cart";
import AdminDashboard from "./components/AdminDashboard";
import api from "./services/api";

export default function App() {
  const [step, setStep] = useState("crop");
  const [croppedFile, setCroppedFile] = useState(null);
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);

  useEffect(() => {
    api.getProducts().then(setProducts);
  }, []);

  const addToCart = (item) => setCart((curr) => [...curr, item]);
  const clearCart = () => setCart([]);

  return (
    <div className="app-container">
      {step === "crop" && (
        <Cropper
          onCropped={(file) => {
            setCroppedFile(file);
            setStep("products");
          }}
        />
      )}

      {step === "products" && (
        <ProductList
          products={products}
          croppedFile={croppedFile}
          onAdd={addToCart}
          onCheckout={() => setStep("checkout")}
        />
      )}

      {step === "checkout" && <Cart cart={cart} onClear={clearCart} />}

      {step === "admin" && <AdminDashboard />}

      <footer>
        <button onClick={() => setStep("admin")}>Admin</button>
      </footer>
    </div>
  );
}
