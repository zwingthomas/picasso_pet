import React, {useEffect, useState} from "react";
import api from "../services/api";

export default function AdminDashboard() {
  const [orders, setOrders] = useState([]);
  useEffect(() => {
    api.listOrders().then(setOrders);
  }, []);

  return (
    <div className="admin-dashboard">
      <h1>Orders</h1>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Email</th>
            <th>Status</th>
            <th>Created</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((o) => (
            <tr key={o.id}>
              <td>{o.id}</td>
              <td>{o.user_email}</td>
              <td>{o.status}</td>
              <td>{new Date(o.created_at).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
