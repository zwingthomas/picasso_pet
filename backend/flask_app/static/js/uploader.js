const form = document.getElementById("upload-form");
const statusEl = document.getElementById("status");

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  statusEl.textContent = "Uploading...";
  const data = new FormData(form);
  try {
    const res = await fetch(`${API_URL}/upload`, {
      method: "POST",
      body: data,
    });
    if (!res.ok) throw new Error("Upload failed");
    const json = await res.json();
    statusEl.innerHTML = `Upload successful!<br>ID: ${json.id}<br>Status: ${json.status}`;
  } catch (err) {
    statusEl.textContent = "Error: " + err.message;
  }
});
