// ShopStream Frontend Application
// ================================

const API_URL = window.location.origin + "/api";
let currentUser = null;
let cart = [];
let products = [];

// ============================================
// Initialization
// ============================================

document.addEventListener("DOMContentLoaded", () => {
  checkAuth();
  loadProducts();
  loadCart();
  checkSystemStatus();
  connectWebSocket();

  // Check system status every 30 seconds
  setInterval(checkSystemStatus, 30000);
});

// ============================================
// Authentication
// ============================================

async function checkAuth() {
  const token = localStorage.getItem("token");
  if (token) {
    try {
      const response = await fetch(`${API_URL}/auth/me`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (response.ok) {
        currentUser = await response.json();
        updateAuthUI();
      } else {
        localStorage.removeItem("token");
      }
    } catch (error) {
      console.error("Auth check failed:", error);
    }
  }
}

function updateAuthUI() {
  const authSection = document.getElementById("authSection");
  if (currentUser) {
    authSection.innerHTML = `
            <div class="dropdown">
                <button class="btn btn-outline-light dropdown-toggle" data-bs-toggle="dropdown">
                    <i class="bi bi-person-circle"></i> ${currentUser.name}
                </button>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="#" onclick="showOrders()">My Orders</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>
                </ul>
            </div>
        `;
  } else {
    authSection.innerHTML = `<button class="btn btn-primary" onclick="showLoginModal()">Login</button>`;
  }
}

async function login(event) {
  event.preventDefault();
  showLoading();

  try {
    const response = await fetch(`${API_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: document.getElementById("loginEmail").value,
        password: document.getElementById("loginPassword").value,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      localStorage.setItem("token", data.token);
      currentUser = data.user;
      updateAuthUI();
      bootstrap.Modal.getInstance(document.getElementById("loginModal")).hide();
      showToast("Welcome back!", "success");
      syncCart();
    } else {
      showToast(data.message || "Login failed", "error");
    }
  } catch (error) {
    showToast("Connection error", "error");
  }

  hideLoading();
}

async function register(event) {
  event.preventDefault();
  showLoading();

  try {
    const response = await fetch(`${API_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: document.getElementById("registerName").value,
        email: document.getElementById("registerEmail").value,
        password: document.getElementById("registerPassword").value,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      bootstrap.Modal.getInstance(
        document.getElementById("registerModal")
      ).hide();
      showToast("Registration successful! Please login.", "success");
      showLoginModal();
    } else {
      showToast(data.message || "Registration failed", "error");
    }
  } catch (error) {
    showToast("Connection error", "error");
  }

  hideLoading();
}

function logout() {
  localStorage.removeItem("token");
  currentUser = null;
  cart = [];
  updateAuthUI();
  updateCartUI();
  showProducts();
  showToast("Logged out successfully", "success");
}

// ============================================
// Products
// ============================================

async function loadProducts() {
  showLoading();

  try {
    const response = await fetch(`${API_URL}/products`);
    products = await response.json();
    renderProducts(products);
    loadCategories();
  } catch (error) {
    showToast("Failed to load products", "error");
  }

  hideLoading();
}

function renderProducts(productsToRender) {
  const grid = document.getElementById("productsGrid");

  if (productsToRender.length === 0) {
    grid.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="bi bi-inbox display-1 text-muted"></i>
                <p class="text-muted mt-3">No products found</p>
            </div>
        `;
    return;
  }

  grid.innerHTML = productsToRender
    .map(
      (product) => `
        <div class="col-md-6 col-lg-4 col-xl-3">
            <div class="card product-card h-100">
                <img src="${
                  product.image ||
                  "https://via.placeholder.com/300x200?text=" +
                    encodeURIComponent(product.name)
                }" 
                     class="card-img-top" alt="${
                       product.name
                     }" style="height: 200px; object-fit: cover;">
                <div class="card-body d-flex flex-column">
                    <span class="badge bg-secondary mb-2" style="width: fit-content;">${
                      product.category
                    }</span>
                    <h5 class="card-title">${product.name}</h5>
                    <p class="card-text text-muted small flex-grow-1">${
                      product.description || ""
                    }</p>
                    <div class="d-flex justify-content-between align-items-center mt-auto">
                        <span class="h5 mb-0 text-primary">$${product.price.toFixed(
                          2
                        )}</span>
                        <button class="btn btn-primary btn-sm" onclick="addToCart(${
                          product.id
                        })">
                            <i class="bi bi-cart-plus"></i> Add
                        </button>
                    </div>
                </div>
                ${
                  product.stock < 10
                    ? `<div class="card-footer text-warning small"><i class="bi bi-exclamation-triangle"></i> Only ${product.stock} left!</div>`
                    : ""
                }
            </div>
        </div>
    `
    )
    .join("");
}

function loadCategories() {
  const categories = [...new Set(products.map((p) => p.category))];
  const select = document.getElementById("categoryFilter");
  select.innerHTML =
    '<option value="">All Categories</option>' +
    categories.map((c) => `<option value="${c}">${c}</option>`).join("");
}

function filterByCategory() {
  const category = document.getElementById("categoryFilter").value;
  const filtered = category
    ? products.filter((p) => p.category === category)
    : products;
  renderProducts(filtered);
}

async function searchProducts(event) {
  event.preventDefault();
  const query = document.getElementById("searchInput").value.trim();

  if (!query) {
    renderProducts(products);
    return;
  }

  showLoading();

  try {
    const response = await fetch(
      `${API_URL}/products/search?q=${encodeURIComponent(query)}`
    );
    const results = await response.json();
    renderProducts(results);
    showProducts();
  } catch (error) {
    showToast("Search failed", "error");
  }

  hideLoading();
}

// ============================================
// Cart
// ============================================

function loadCart() {
  const savedCart = localStorage.getItem("cart");
  if (savedCart) {
    cart = JSON.parse(savedCart);
    updateCartUI();
  }
}

function saveCart() {
  localStorage.setItem("cart", JSON.stringify(cart));
}

async function syncCart() {
  if (!currentUser) return;

  const token = localStorage.getItem("token");
  try {
    // Sync local cart to server
    if (cart.length > 0) {
      await fetch(`${API_URL}/cart/sync`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ items: cart }),
      });
    }

    // Get cart from server
    const response = await fetch(`${API_URL}/cart`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    if (response.ok) {
      cart = await response.json();
      saveCart();
      updateCartUI();
    }
  } catch (error) {
    console.error("Cart sync failed:", error);
  }
}

function addToCart(productId) {
  const product = products.find((p) => p.id === productId);
  if (!product) return;

  const existingItem = cart.find((item) => item.productId === productId);

  if (existingItem) {
    existingItem.quantity++;
  } else {
    cart.push({
      productId: productId,
      name: product.name,
      price: product.price,
      image: product.image,
      quantity: 1,
    });
  }

  saveCart();
  updateCartUI();
  showToast(`${product.name} added to cart`, "success");

  // Sync with server if logged in
  if (currentUser) {
    syncCartItem(productId, 1);
  }
}

async function syncCartItem(productId, quantity) {
  const token = localStorage.getItem("token");
  try {
    await fetch(`${API_URL}/cart/add`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ productId, quantity }),
    });
  } catch (error) {
    console.error("Failed to sync cart item:", error);
  }
}

function updateCartQuantity(productId, delta) {
  const item = cart.find((i) => i.productId === productId);
  if (!item) return;

  item.quantity += delta;

  if (item.quantity <= 0) {
    cart = cart.filter((i) => i.productId !== productId);
  }

  saveCart();
  updateCartUI();
  renderCart();
}

function removeFromCart(productId) {
  cart = cart.filter((i) => i.productId !== productId);
  saveCart();
  updateCartUI();
  renderCart();
}

function updateCartUI() {
  const count = cart.reduce((sum, item) => sum + item.quantity, 0);
  document.getElementById("cartCount").textContent = count;
}

function renderCart() {
  const cartItems = document.getElementById("cartItems");

  if (cart.length === 0) {
    cartItems.innerHTML = `
            <div class="text-center py-5">
                <i class="bi bi-cart-x display-1 text-muted"></i>
                <p class="text-muted mt-3">Your cart is empty</p>
                <button class="btn btn-primary" onclick="showProducts()">Start Shopping</button>
            </div>
        `;
    document.getElementById("cartSubtotal").textContent = "$0.00";
    document.getElementById("cartShipping").textContent = "$0.00";
    document.getElementById("cartTotal").textContent = "$0.00";
    return;
  }

  cartItems.innerHTML = cart
    .map(
      (item) => `
        <div class="card mb-3">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-2">
                        <img src="${
                          item.image ||
                          "https://via.placeholder.com/100x100?text=" +
                            encodeURIComponent(item.name)
                        }" 
                             class="img-fluid rounded" alt="${item.name}">
                    </div>
                    <div class="col-md-4">
                        <h6 class="mb-0">${item.name}</h6>
                        <small class="text-muted">$${item.price.toFixed(
                          2
                        )} each</small>
                    </div>
                    <div class="col-md-3">
                        <div class="input-group input-group-sm">
                            <button class="btn btn-outline-secondary" onclick="updateCartQuantity(${
                              item.productId
                            }, -1)">-</button>
                            <span class="input-group-text">${
                              item.quantity
                            }</span>
                            <button class="btn btn-outline-secondary" onclick="updateCartQuantity(${
                              item.productId
                            }, 1)">+</button>
                        </div>
                    </div>
                    <div class="col-md-2 text-end">
                        <strong>$${(item.price * item.quantity).toFixed(
                          2
                        )}</strong>
                    </div>
                    <div class="col-md-1 text-end">
                        <button class="btn btn-sm btn-outline-danger" onclick="removeFromCart(${
                          item.productId
                        })">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `
    )
    .join("");

  const subtotal = cart.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );
  const shipping = subtotal > 50 ? 0 : 9.99;
  const total = subtotal + shipping;

  document.getElementById("cartSubtotal").textContent = `$${subtotal.toFixed(
    2
  )}`;
  document.getElementById("cartShipping").textContent =
    shipping === 0 ? "FREE" : `$${shipping.toFixed(2)}`;
  document.getElementById("cartTotal").textContent = `$${total.toFixed(2)}`;
}

// ============================================
// Checkout & Orders
// ============================================

async function checkout() {
  if (!currentUser) {
    showToast("Please login to checkout", "warning");
    showLoginModal();
    return;
  }

  if (cart.length === 0) {
    showToast("Your cart is empty", "warning");
    return;
  }

  showLoading();

  const token = localStorage.getItem("token");

  try {
    const response = await fetch(`${API_URL}/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        items: cart.map((item) => ({
          productId: item.productId,
          quantity: item.quantity,
        })),
      }),
    });

    const data = await response.json();

    if (response.ok) {
      cart = [];
      saveCart();
      updateCartUI();
      showToast(`Order #${data.orderId} placed successfully!`, "success");
      showOrders();
    } else {
      showToast(data.message || "Checkout failed", "error");
    }
  } catch (error) {
    showToast("Connection error", "error");
  }

  hideLoading();
}

async function loadOrders() {
  if (!currentUser) {
    document.getElementById("ordersList").innerHTML = `
            <div class="text-center py-5">
                <i class="bi bi-box-seam display-1 text-muted"></i>
                <p class="text-muted mt-3">Please login to view your orders</p>
                <button class="btn btn-primary" onclick="showLoginModal()">Login</button>
            </div>
        `;
    return;
  }

  showLoading();

  const token = localStorage.getItem("token");

  try {
    const response = await fetch(`${API_URL}/orders`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    const orders = await response.json();
    renderOrders(orders);
  } catch (error) {
    showToast("Failed to load orders", "error");
  }

  hideLoading();
}

function renderOrders(orders) {
  const ordersList = document.getElementById("ordersList");

  if (orders.length === 0) {
    ordersList.innerHTML = `
            <div class="text-center py-5">
                <i class="bi bi-box-seam display-1 text-muted"></i>
                <p class="text-muted mt-3">You haven't placed any orders yet</p>
                <button class="btn btn-primary" onclick="showProducts()">Start Shopping</button>
            </div>
        `;
    return;
  }

  const statusColors = {
    pending: "warning",
    processing: "info",
    shipped: "primary",
    delivered: "success",
    cancelled: "danger",
  };

  ordersList.innerHTML = orders
    .map(
      (order) => `
        <div class="card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <div>
                    <strong>Order #${order.id}</strong>
                    <small class="text-muted ms-3">${new Date(
                      order.createdAt
                    ).toLocaleDateString()}</small>
                </div>
                <span class="badge bg-${
                  statusColors[order.status] || "secondary"
                }">${order.status.toUpperCase()}</span>
            </div>
            <div class="card-body">
                <div class="row">
                    ${order.items
                      .map(
                        (item) => `
                        <div class="col-md-6 mb-2">
                            <div class="d-flex align-items-center">
                                <img src="${
                                  item.image || "https://via.placeholder.com/50"
                                }" 
                                     class="rounded me-2" width="50" height="50" style="object-fit: cover;">
                                <div>
                                    <div>${item.name}</div>
                                    <small class="text-muted">Qty: ${
                                      item.quantity
                                    } × $${item.price.toFixed(2)}</small>
                                </div>
                            </div>
                        </div>
                    `
                      )
                      .join("")}
                </div>
            </div>
            <div class="card-footer d-flex justify-content-between">
                <span>Total: <strong>$${order.total.toFixed(2)}</strong></span>
                ${
                  order.status === "pending"
                    ? `<button class="btn btn-sm btn-outline-danger" onclick="cancelOrder(${order.id})">Cancel Order</button>`
                    : ""
                }
            </div>
        </div>
    `
    )
    .join("");
}

async function cancelOrder(orderId) {
  if (!confirm("Are you sure you want to cancel this order?")) return;

  const token = localStorage.getItem("token");

  try {
    const response = await fetch(`${API_URL}/orders/${orderId}/cancel`, {
      method: "POST",
      headers: { Authorization: `Bearer ${token}` },
    });

    if (response.ok) {
      showToast("Order cancelled successfully", "success");
      loadOrders();
    } else {
      showToast("Failed to cancel order", "error");
    }
  } catch (error) {
    showToast("Connection error", "error");
  }
}

// ============================================
// WebSocket (Notifications)
// ============================================

function connectWebSocket() {
  const wsProtocol = window.location.protocol === "https:" ? "wss:" : "ws:";
  const wsUrl = `${wsProtocol}//${window.location.host}/ws`;

  try {
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log("WebSocket connected");
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      handleNotification(data);
    };

    ws.onclose = () => {
      console.log("WebSocket disconnected, reconnecting...");
      setTimeout(connectWebSocket, 5000);
    };

    ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };
  } catch (error) {
    console.error("WebSocket connection failed:", error);
  }
}

function handleNotification(data) {
  switch (data.type) {
    case "order_update":
      showToast(`Order #${data.orderId} status: ${data.status}`, "info");
      if (document.getElementById("ordersSection").style.display !== "none") {
        loadOrders();
      }
      break;
    case "promotion":
      showToast(data.message, "info");
      break;
    default:
      console.log("Unknown notification:", data);
  }
}

// ============================================
// System Status
// ============================================

async function checkSystemStatus() {
  try {
    const response = await fetch(`${API_URL}/health`);
    const health = await response.json();

    setStatusIndicator("apiStatus", health.status === "healthy");
    setStatusIndicator("dbStatus", health.database === "connected");
    setStatusIndicator("cacheStatus", health.cache === "connected");
  } catch (error) {
    setStatusIndicator("apiStatus", false);
    setStatusIndicator("dbStatus", false);
    setStatusIndicator("cacheStatus", false);
  }
}

function setStatusIndicator(id, isOnline) {
  const indicator = document.getElementById(id);
  indicator.className = `status-indicator ${
    isOnline ? "status-online" : "status-offline"
  }`;
}

// ============================================
// UI Helpers
// ============================================

function showProducts() {
  document.getElementById("heroSection").style.display = "block";
  document.getElementById("productsSection").style.display = "block";
  document.getElementById("cartSection").style.display = "none";
  document.getElementById("ordersSection").style.display = "none";
}

function showCart() {
  document.getElementById("heroSection").style.display = "none";
  document.getElementById("productsSection").style.display = "none";
  document.getElementById("cartSection").style.display = "block";
  document.getElementById("ordersSection").style.display = "none";
  renderCart();
}

function showOrders() {
  document.getElementById("heroSection").style.display = "none";
  document.getElementById("productsSection").style.display = "none";
  document.getElementById("cartSection").style.display = "none";
  document.getElementById("ordersSection").style.display = "block";
  loadOrders();
}

function showLoginModal() {
  const registerModal = bootstrap.Modal.getInstance(
    document.getElementById("registerModal")
  );
  if (registerModal) registerModal.hide();
  new bootstrap.Modal(document.getElementById("loginModal")).show();
}

function showRegisterModal() {
  const loginModal = bootstrap.Modal.getInstance(
    document.getElementById("loginModal")
  );
  if (loginModal) loginModal.hide();
  new bootstrap.Modal(document.getElementById("registerModal")).show();
}

function showLoading() {
  document.getElementById("loading").style.display = "flex";
}

function hideLoading() {
  document.getElementById("loading").style.display = "none";
}

function showToast(message, type = "info") {
  const container = document.getElementById("toastContainer");
  const id = "toast-" + Date.now();

  const bgColor =
    {
      success: "bg-success",
      error: "bg-danger",
      warning: "bg-warning",
      info: "bg-info",
    }[type] || "bg-info";

  const icon =
    {
      success: "bi-check-circle",
      error: "bi-x-circle",
      warning: "bi-exclamation-triangle",
      info: "bi-info-circle",
    }[type] || "bi-info-circle";

  container.innerHTML += `
        <div id="${id}" class="toast ${bgColor} text-white" role="alert">
            <div class="toast-body d-flex align-items-center">
                <i class="bi ${icon} me-2"></i>
                ${message}
                <button type="button" class="btn-close btn-close-white ms-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;

  const toastEl = document.getElementById(id);
  const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
  toast.show();

  toastEl.addEventListener("hidden.bs.toast", () => toastEl.remove());
}
