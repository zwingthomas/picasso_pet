import axios from "axios";

const API_BASE = process.env.REACT_APP_API_URL || "http://localhost:8000/api";

export default {
  getProducts: () => axios.get(`${API_BASE}/products`).then((res) => res.data),
  uploadImage: (formData) =>
    axios.post(`${API_BASE}/upload`, formData).then((res) => res.data),
  createCheckout: (order) =>
    axios.post(`${API_BASE}/create-checkout`, order).then((res) => res.data),
  listOrders: () =>
    axios.get(`${API_BASE}/admin/orders`).then((res) => res.data),
};
