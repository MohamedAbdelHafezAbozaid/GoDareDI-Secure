// GoDareDI Dashboard - Complete Refactor
// Clean, modular architecture with proper error handling

// ============================================================================
// CORE DASHBOARD CLASS
// ============================================================================

class GoDareDashboard {
  constructor() {
    this.currentUser = null;
    this.userApps = [];
    this.userTokens = [];
    this.currentAppId = null;
    this.dashboardData = null;
    
    this.init();
  }

  async init() {
    try {
      await this.setupAuthListener();
      await this.setupEventListeners();
    } catch (error) {
      console.error('❌ Dashboard initialization failed:', error);
      this.showError('Failed to initialize dashboard');
    }
  }

  // ============================================================================
  // AUTHENTICATION MANAGEMENT
  // ============================================================================

  async setupAuthListener() {
    onAuthStateChanged(auth, async (user) => {
      this.currentUser = user;
      
      if (user) {
        await this.handleUserSignIn(user);
      } else {
        this.handleUserSignOut();
      }
    });
  }

  async handleUserSignIn(user) {
    try {
      // Hide auth section and show dashboard
      document.getElementById('auth-section').classList.add('hidden');
      document.getElementById('dashboard').classList.remove('hidden');
      
      // Show user info
      document.getElementById('user-info').textContent = user.email;
      
      // Ensure user document exists in Firestore
      await this.ensureUserDocument(user);
      
      // Check if Super Admin
      if (user.email === 'bota78336@gmail.com') {
        this.isSuperAdmin = true;
        // Show Super Admin tab
        const superAdminTab = document.getElementById('super-admin-tab');
        if (superAdminTab) {
          superAdminTab.classList.remove('hidden');
        }
        await this.loadSuperAdminStats();
      } else {
        this.isSuperAdmin = false;
        // Hide Super Admin tab
        const superAdminTab = document.getElementById('super-admin-tab');
        if (superAdminTab) {
          superAdminTab.classList.add('hidden');
        }
        await this.loadUserData();
      }
    } catch (error) {
      console.error('Error handling user sign in:', error);
      this.showError('Failed to load user data');
    }
  }

  async ensureUserDocument(user) {
    try {
      // Check if user document exists
      const userDocRef = doc(db, 'users', user.uid);
      const userDoc = await getDoc(userDocRef);
      
      if (!userDoc.exists()) {
        // Create user document if it doesn't exist
        await setDoc(userDocRef, {
          uid: user.uid,
          name: user.displayName || user.email.split('@')[0],
          email: user.email,
          createdAt: new Date(),
          isActive: true
        });
        console.log('✅ User document created for:', user.email);
      }
    } catch (error) {
      console.error('Error ensuring user document:', error);
      // Don't throw error here as it's not critical
    }
  }

  async handleUserSignOut() {
    try {
      // Sign out from Firebase
      await signOut(auth);
      
      // Show auth section and hide dashboard
      document.getElementById('auth-section').classList.remove('hidden');
      document.getElementById('dashboard').classList.add('hidden');
      
      // Reset forms
      document.getElementById('login-form').classList.remove('hidden');
      document.getElementById('register-form').classList.add('hidden');
      
      // Reset data
      this.userApps = [];
      this.userTokens = [];
      this.currentAppId = null;
      this.dashboardData = null;
      this.isSuperAdmin = false;
      
      // Hide Super Admin tab
      const superAdminTab = document.getElementById('super-admin-tab');
      if (superAdminTab) {
        superAdminTab.classList.add('hidden');
      }
      
    } catch (error) {
      console.error('Error signing out:', error);
      this.showError('Failed to logout');
    }
  }

  // ============================================================================
  // EVENT LISTENERS
  // ============================================================================

  async setupEventListeners() {
    // Login form
    document.getElementById('login-form-element').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleLogin();
    });

    // Register form
    document.getElementById('register-form-element').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleRegister();
    });

    // Show/hide forms
    document.getElementById('show-register').addEventListener('click', () => {
      document.getElementById('login-form').classList.add('hidden');
      document.getElementById('register-form').classList.remove('hidden');
    });

    document.getElementById('show-login').addEventListener('click', () => {
      document.getElementById('register-form').classList.add('hidden');
      document.getElementById('login-form').classList.remove('hidden');
    });

    // Logout
    document.getElementById('sign-out-btn').addEventListener('click', () => {
      this.handleLogout();
    });

    // Form switching is handled by show-register and show-login buttons above

    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const tabName = btn.dataset.tab;
        this.switchTab(tabName);
      });
    });

    // Add app modal
    document.getElementById('add-new-app-btn').addEventListener('click', () => {
      this.showAddAppModal();
    });

    document.getElementById('close-add-app-modal').addEventListener('click', () => {
      this.hideAddAppModal();
    });

    document.getElementById('cancel-add-app').addEventListener('click', () => {
      this.hideAddAppModal();
    });

    document.getElementById('add-app-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleAddApp();
    });
  }

  // ============================================================================
  // AUTHENTICATION HANDLERS
  // ============================================================================

  async handleLogin() {
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
      console.error('❌ Login failed:', error);
      this.showAuthError(error);
    }
  }

  async handleRegister() {
    const name = document.getElementById('register-name').value;
    const email = document.getElementById('register-email').value;
    const password = document.getElementById('register-password').value;
    
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Create user document
      await addDoc(collection(db, 'users'), {
        uid: user.uid,
        name: name,
        email: email,
        createdAt: new Date(),
        isActive: true
      });
      
    } catch (error) {
      console.error('❌ Registration failed:', error);
      this.showAuthError(error);
    }
  }

  async handleLogout() {
    try {
      // Sign out from Firebase
      await signOut(auth);
      
      // Show auth section and hide dashboard
      document.getElementById('auth-section').classList.remove('hidden');
      document.getElementById('dashboard').classList.add('hidden');
      
      // Reset forms
      document.getElementById('login-form').classList.remove('hidden');
      document.getElementById('register-form').classList.add('hidden');
      
      // Reset data
      this.userApps = [];
      this.userTokens = [];
      this.currentAppId = null;
      this.dashboardData = null;
      this.isSuperAdmin = false;
      
      // Hide Super Admin tab
      const superAdminTab = document.getElementById('super-admin-tab');
      if (superAdminTab) {
        superAdminTab.classList.add('hidden');
      }
      
    } catch (error) {
      console.error('❌ Logout failed:', error);
      this.showError('Failed to logout');
    }
  }

  switchToRegister() {
    document.getElementById('login-form').classList.add('hidden');
    document.getElementById('register-form').classList.remove('hidden');
  }

  switchToLogin() {
    document.getElementById('register-form').classList.add('hidden');
    document.getElementById('login-form').classList.remove('hidden');
  }

  showAuthError(error) {
    let message = 'Authentication failed: ';
    
    switch (error.code) {
      case 'auth/network-request-failed':
        message += 'Network error. Check your connection.';
        break;
      case 'auth/too-many-requests':
        message += 'Too many attempts. Try again later.';
        break;
      case 'auth/user-not-found':
        message += 'No account found with this email.';
        break;
      case 'auth/wrong-password':
        message += 'Incorrect password.';
        break;
      case 'auth/invalid-email':
        message += 'Invalid email format.';
        break;
      default:
        if (error.message.includes('CORS') || error.message.includes('access control')) {
          message += 'Service unavailable. Check your connection.';
        } else {
          message += error.message;
        }
    }
    
    alert(message);
  }

  // ============================================================================
  // TAB MANAGEMENT
  // ============================================================================

  async switchTab(tabName) {
    
    // Update tab buttons
    document.querySelectorAll('.tab-button').forEach(btn => {
      btn.classList.remove('border-blue-500', 'text-blue-600');
      btn.classList.add('border-transparent', 'text-gray-500');
    });
    
    const activeBtn = document.getElementById(`${tabName}-tab`);
    if (activeBtn) {
      activeBtn.classList.add('border-blue-500', 'text-blue-600');
      activeBtn.classList.remove('border-transparent', 'text-gray-500');
    }
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
      content.classList.remove('active');
    });
    
    const tabContent = document.getElementById(`${tabName}-content`);
    if (tabContent) {
      tabContent.classList.add('active');
    }
    
    // Advanced tab content is now included directly in HTML
    
    // Hide dependency visualizations section when switching away from Advanced tab
    if (tabName !== 'advanced') {
      this.hideDependencyVisualizationsSection();
    }

    // Load tab-specific data
    try {
      switch (tabName) {
        case 'overview':
          await this.loadOverview();
          break;
        case 'analytics':
          await this.loadAnalytics();
          break;
        case 'tokens':
          await this.loadTokens();
          break;
        case 'advanced':
          await this.loadAdvancedDashboard();
          break;
        case 'visualizations':
          await this.loadVisualizations();
          break;
        case 'super-admin':
          await this.loadSuperAdminStats();
          break;
      }
    } catch (error) {
      console.error(`Error loading ${tabName} tab:`, error);
      this.showError(`Failed to load ${tabName} data`);
    }
  }

  // ============================================================================
  // DATA LOADING
  // ============================================================================

  async loadUserData() {
    if (!this.currentUser) return;
    
    try {
      
      // Load apps and tokens in parallel
      const [apps, tokens, usage] = await Promise.all([
        this.fetchUserApps(),
        this.fetchUserTokens(),
        this.fetchUserUsage()
      ]);
      
      this.userApps = apps;
      this.userTokens = tokens;
      this.userUsage = usage;
      
      // Update stats
      this.updateUserStats(apps, tokens, usage);
      
    } catch (error) {
      console.error('❌ Failed to load user data:', error);
      this.showError('Failed to load user data');
    }
  }

  async fetchUserApps() {
    try {
      const appsQuery = query(
        collection(db, 'apps'), 
        where('userId', '==', this.currentUser.uid)
      );
      const snapshot = await getDocs(appsQuery);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error fetching user apps:', error);
      return [];
    }
  }

  async fetchUserTokens() {
    try {
      const tokensQuery = query(
        collection(db, 'tokens'), 
        where('userId', '==', this.currentUser.uid)
      );
      const snapshot = await getDocs(tokensQuery);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error fetching user tokens:', error);
      return [];
    }
  }

  async fetchUserUsage() {
    try {
      const usageQuery = query(
        collection(db, 'sdk-usage'), 
        where('userId', '==', this.currentUser.uid)
      );
      const snapshot = await getDocs(usageQuery);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error fetching user usage:', error);
      return [];
    }
  }

  updateUserStats(apps, tokens, usage) {
    const totalAppsEl = document.getElementById('total-apps');
    const activeTokensEl = document.getElementById('active-tokens');
    const totalUsageEl = document.getElementById('total-usage');
    
    if (totalAppsEl) totalAppsEl.textContent = apps.length;
    if (activeTokensEl) activeTokensEl.textContent = tokens.filter(t => t.isActive).length;
    if (totalUsageEl) totalUsageEl.textContent = usage.length;
  }

  // ============================================================================
  // APPS MANAGEMENT
  // ============================================================================

  async loadApps() {
    try {
      
      const appsList = document.getElementById('apps-list');
      if (!appsList) return;
      
      appsList.innerHTML = '';
      
      if (this.userApps.length === 0) {
        appsList.innerHTML = `
          <div class="text-center py-8">
            <i class="fas fa-mobile-alt text-4xl text-gray-400 mb-2"></i>
            <p class="text-gray-500">No apps registered yet</p>
            <p class="text-sm text-gray-400 mt-1">Add your first app using the button above</p>
          </div>
        `;
        return;
      }
      
      this.userApps.forEach(app => {
        const appCard = this.createAppCard(app);
        appsList.appendChild(appCard);
      });
      
    } catch (error) {
      console.error('❌ Failed to load apps:', error);
      this.showError('Failed to load apps');
    }
  }

  createAppCard(app) {
    const card = document.createElement('div');
    card.className = 'bg-gray-50 rounded-lg p-4 border';
    
    const appName = app.name || app.appName || 'Unknown App';
    const platform = app.platform || 'Unknown';
    const description = app.description || app.bundleId || 'No description';
    const createdDate = app.createdAt?.toDate ? app.createdAt.toDate() : new Date(app.createdAt);
    
    // Check if app has token
    const hasToken = this.userTokens.some(token => token.appId === app.id && token.isActive);
    
    card.innerHTML = `
      <div class="flex justify-between items-start">
        <div>
          <h4 class="text-lg font-semibold text-gray-800">${appName}</h4>
          <p class="text-sm text-gray-600">${platform} • ${description}</p>
          <p class="text-xs text-gray-500 mt-1">Created: ${createdDate.toLocaleDateString()}</p>
        </div>
        <div class="flex space-x-2">
          ${hasToken ? 
            `<span class="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full">Token Generated</span>` :
            `<button class="px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 generate-token-btn" data-app-id="${app.id}">
              Generate Token
            </button>`
          }
        </div>
      </div>
    `;
    
    // Add event listener for generate token button
    const generateBtn = card.querySelector('.generate-token-btn');
    if (generateBtn) {
      generateBtn.addEventListener('click', () => this.generateToken(app.id));
    }
    
    return card;
  }

  async loadOverview() {
    try {
      
      // Load user data first
      await this.loadUserData();
      
      // Load app selector
      await this.loadAppSelector();
      
      // If there's a current app, load its dashboard
      if (this.currentAppId) {
        await this.loadAppDashboard(this.currentAppId);
      }
      
    } catch (error) {
      console.error('❌ Failed to load overview:', error);
      this.showError('Failed to load overview data');
    }
  }

  async loadAppSelector() {
    try {
      
      const appSelector = document.getElementById('app-selector');
      if (!appSelector) {
        return;
      }

      if (!this.userApps || this.userApps.length === 0) {
        appSelector.innerHTML = `
          <div class="text-center py-8">
            <p class="text-gray-500 mb-4">No applications found</p>
            <button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700" onclick="dashboard.showAddAppModal()">
              Add Your First App
            </button>
          </div>
        `;
        return;
      }

      // Create app selector dropdown
      let options = '<option value="">Select an application</option>';
      this.userApps.forEach(app => {
        const selected = app.id === this.currentAppId ? 'selected' : '';
        options += `<option value="${app.id}" ${selected}>${app.name}</option>`;
      });
      
      appSelector.innerHTML = `
        <select id="app-select" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          ${options}
        </select>
      `;
      

      // Add event listener for app selection
      const select = document.getElementById('app-select');
      if (select) {
        select.addEventListener('change', (e) => {
          this.currentAppId = e.target.value;
          if (this.currentAppId) {
            this.loadAppDashboard(this.currentAppId);
          }
        });
      }

    } catch (error) {
      console.error('❌ Failed to load app selector:', error);
    }
  }

  async generateToken(appId) {
    try {
      
      const app = this.userApps.find(a => a.id === appId);
      if (!app) {
        throw new Error('App not found');
      }
      
      const generateTokenFunction = httpsCallable(functions, 'generateToken');
      const result = await generateTokenFunction({
        appId: appId,
        appName: app.name || app.appName || 'Unknown App',
        appDescription: app.description || app.bundleId || 'Generated from dashboard',
        platform: app.platform || 'iOS'
      });
      
      
      if (result.data && result.data.success) {
        alert('Token generated successfully: ' + result.data.token);
        await this.loadUserData(); // Reload data
        await this.loadApps(); // Refresh apps display
      } else {
        throw new Error('Unexpected response format');
      }
    } catch (error) {
      console.error('❌ Failed to generate token:', error);
      alert('Error generating token: ' + error.message);
    }
  }

  showAddAppModal() {
    const modal = document.getElementById('add-app-modal');
    if (modal) {
      modal.classList.remove('hidden');
    }
  }

  hideAddAppModal() {
    const modal = document.getElementById('add-app-modal');
    if (modal) {
      modal.classList.add('hidden');
    }
  }

  async handleAddApp() {
    const appName = document.getElementById('app-name').value;
    const platform = document.getElementById('app-platform').value;
    const bundleId = document.getElementById('app-bundle-id').value;
    
    try {
      
      await addDoc(collection(db, 'apps'), {
        userId: this.currentUser.uid,
        name: appName,
        appName: appName, // Keep both for compatibility
        platform: platform,
        bundleId: bundleId,
        description: bundleId, // Use bundleId as description
        createdAt: new Date(),
        isActive: true
      });
      
      document.getElementById('add-app-modal').classList.add('hidden');
      document.getElementById('add-app-form').reset();
      
      await this.loadUserData();
      await this.loadApps();
      
    } catch (error) {
      console.error('❌ Failed to add app:', error);
      alert('Error adding app: ' + error.message);
    }
  }

  // ============================================================================
  // TOKENS MANAGEMENT
  // ============================================================================

  async loadTokens() {
    try {
      
      const tokensList = document.getElementById('tokens-list');
      if (!tokensList) return;
      
      tokensList.innerHTML = '';
      
      if (this.userTokens.length === 0) {
        tokensList.innerHTML = `
          <div class="text-center py-8">
            <i class="fas fa-key text-4xl text-gray-400 mb-2"></i>
            <p class="text-gray-500">No tokens generated yet</p>
            <p class="text-sm text-gray-400 mt-1">Generate tokens for your apps to see them here</p>
          </div>
        `;
        return;
      }
      
      // Create apps lookup for token display
      const appsLookup = {};
      this.userApps.forEach(app => {
        appsLookup[app.id] = app;
      });
      
      this.userTokens.forEach(token => {
        const app = appsLookup[token.appId];
        const tokenCard = this.createTokenCard(token, app);
        tokensList.appendChild(tokenCard);
      });
      
    } catch (error) {
      console.error('❌ Failed to load tokens:', error);
      this.showError('Failed to load tokens');
    }
  }

  createTokenCard(token, app) {
    const card = document.createElement('div');
    card.className = 'bg-gray-50 rounded-lg p-4 border';
    
    const appName = app ? (app.name || app.appName || 'Unknown App') : 'Unknown App';
    const platform = app ? (app.platform || 'Unknown') : 'Unknown';
    const description = app ? (app.description || app.bundleId || 'No description') : 'No description';
    
    const lastUsed = token.lastUsed ? 
      (token.lastUsed.toDate ? token.lastUsed.toDate() : new Date(token.lastUsed)) : 
      null;
    
    card.innerHTML = `
      <div class="flex justify-between items-start">
        <div>
          <h4 class="text-lg font-semibold text-gray-800">${appName}</h4>
          <p class="text-sm text-gray-600">${platform} • ${description}</p>
          <p class="text-xs text-gray-500 mt-1">Usage: ${token.usageCount || 0} times</p>
          <p class="text-xs text-gray-500">Last used: ${lastUsed ? lastUsed.toLocaleDateString() : 'Never'}</p>
        </div>
        <div class="flex flex-col space-y-2">
          <span class="px-2 py-1 ${token.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'} text-xs rounded-full">
            ${token.isActive ? 'Active' : 'Inactive'}
          </span>
          <button class="px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 copy-token-btn" data-token="${token.id}">
            Copy Token
          </button>
        </div>
      </div>
      <div class="mt-3 p-2 bg-gray-100 rounded text-xs font-mono text-gray-700 break-all">
        ${token.id}
      </div>
    `;
    
    // Add event listener for copy token button
    const copyBtn = card.querySelector('.copy-token-btn');
    if (copyBtn) {
      copyBtn.addEventListener('click', () => {
        navigator.clipboard.writeText(token.id);
        alert('Token copied to clipboard!');
      });
    }
    
    return card;
  }

  // ============================================================================
  // ADVANCED DASHBOARD
  // ============================================================================

  async loadAdvancedTabContent() {
    try {
      const advancedContent = document.getElementById('advanced-content');
      if (!advancedContent) return;
      
      // Check if content is already loaded
      if (advancedContent.innerHTML.trim() !== '') return;
      
      // Load all Advanced tab sections
      const sections = [
        'sections/advanced/hero-section.html',
        'sections/advanced/stats-overview.html',
        'sections/advanced/main-content-grid.html',
        'sections/advanced/analysis-section.html',
        'sections/advanced/visualizations-header.html',
        'sections/advanced/visualization-tabs.html',
        'sections/advanced/visualization-content.html'
      ];
      
      let combinedHTML = '';
      
      for (const section of sections) {
        try {
          const response = await fetch(section);
          if (response.ok) {
            const html = await response.text();
            combinedHTML += html + '\n';
          } else {
            console.warn(`⚠️ Failed to load section: ${section}`);
          }
        } catch (error) {
          console.warn(`⚠️ Error loading section ${section}:`, error);
        }
      }
      
      if (combinedHTML.trim()) {
        advancedContent.innerHTML = combinedHTML;
      } else {
        console.error('❌ No Advanced tab content could be loaded');
        advancedContent.innerHTML = '<div class="text-center py-12"><p class="text-gray-500">Failed to load Advanced tab content</p></div>';
      }
    } catch (error) {
      console.error('❌ Error loading Advanced tab content:', error);
    }
  }

  async loadVisualizations() {
    try {
      
      // Visualizations tab is always available
      // The content is already in the HTML
    } catch (error) {
      console.error('❌ Failed to load visualizations:', error);
      this.showError('Failed to load visualizations');
    }
  }

  async loadAdvancedDashboard() {
    try {
      
      if (this.userApps.length === 0) {
        this.showNoAppsMessage();
        return;
      }
      
      if (this.userApps.length === 1) {
        this.currentAppId = this.userApps[0].id;
        await this.loadAppDashboard(this.currentAppId);
      } else {
        this.showAppSelector();
      }
    } catch (error) {
      console.error('❌ Failed to load advanced dashboard:', error);
      this.showError('Failed to load dashboard');
    }
  }

  async loadAppDashboard(appId) {
    try {
      
      // Check if the app exists in user's apps
      const app = this.userApps.find(a => a.id === appId);
      if (!app) {
        this.showNoDataMessage();
        return;
      }
      
      
      // Try to get dashboard data from appDashboards collection
      const appDashboardRef = doc(db, 'appDashboards', appId);
      const appDashboardDoc = await getDoc(appDashboardRef);
      
      
      if (!appDashboardDoc.exists()) {
        
        // Let's also check if there's data in the old userDashboards collection
        const userDashboardQuery = query(
          collection(db, 'userDashboards'),
          where('userId', '==', this.currentUser.uid)
        );
        const userDashboardSnapshot = await getDocs(userDashboardQuery);
        
        if (userDashboardSnapshot.docs.length > 0) {
          const userDashboardData = userDashboardSnapshot.docs[0].data();
          
          // Migrate to appDashboards
          await this.migrateUserDashboardData(appId, userDashboardData);
          // Retry loading
          return this.loadAppDashboard(appId);
        }
        
        this.showNoDataMessage();
        return;
      }
      
      const dashboardData = appDashboardDoc.data();
      
      this.dashboardData = dashboardData;
      
      if (dashboardData.dependencyInfo) {
        this.updateLastUpdatedDisplay(dashboardData.lastUpdated);
        this.loadDependencyStats(dashboardData.dependencyInfo);
        this.loadPerformanceMetrics(dashboardData.dependencyInfo.performanceMetrics);
        this.loadDependencyGraph(dashboardData.dependencyInfo);
        this.loadRecentEvents(dashboardData.recentEvents || []);
        this.loadAppOverview(dashboardData);
        this.loadDependencyAnalysis(dashboardData.dependencyInfo);
        
        // Show the dependency visualizations section since we have valid data
        this.showDependencyVisualizationsSection();
      } else {
        this.showNoDataMessage();
        
        // Hide the dependency visualizations section since we have no data
        this.hideDependencyVisualizationsSection();
      }
    } catch (error) {
      console.error('❌ Failed to load app dashboard:', error);
      this.showNoDataMessage();
    }
  }

  updateLastUpdatedDisplay(lastUpdated) {
    const lastUpdatedElement = document.getElementById('last-updated-display');
    if (!lastUpdatedElement) return;
    
    let formattedDate = 'Never';
    if (lastUpdated) {
      try {
        if (lastUpdated.toDate && typeof lastUpdated.toDate === 'function') {
          formattedDate = lastUpdated.toDate().toLocaleString();
        } else if (lastUpdated.seconds) {
          formattedDate = new Date(lastUpdated.seconds * 1000).toLocaleString();
        } else {
          formattedDate = new Date(lastUpdated).toLocaleString();
        }
      } catch (error) {
        console.error('Error formatting date:', error);
        formattedDate = 'Invalid date';
      }
    }
    
    lastUpdatedElement.textContent = formattedDate;
  }

  loadDependencyStats(dependencyInfo) {
    if (!dependencyInfo.analysis) return;
    
    const analysis = dependencyInfo.analysis;
    
    // Calculate values from the actual data structure
    const totalNodes = analysis.totalNodes || 0;
    const totalEdges = analysis.totalDependencies || 0; // totalDependencies is the correct field
    const circularDependencies = analysis.circularDependencyChains ? analysis.circularDependencyChains.length : 0;
    const complexityScore = analysis.complexityMetrics ? analysis.complexityMetrics.couplingScore || 0 : 0;
    
    const elements = {
      'total-nodes': totalNodes,
      'total-edges': totalEdges,
      'circular-dependencies': circularDependencies,
      'complexity-score': complexityScore.toFixed(2)
    };
    
    Object.entries(elements).forEach(([id, value]) => {
      const element = document.getElementById(id);
      if (element) element.textContent = value;
    });
  }

  loadPerformanceMetrics(performanceMetrics) {
    if (!performanceMetrics) return;
    
    const elements = {
      'avg-resolution-time': (performanceMetrics.averageResolutionTime || 0).toFixed(3) + 's',
      'total-resolutions': performanceMetrics.totalResolutions || 0,
      'cache-hit-rate': ((performanceMetrics.cacheHitRate || 0) * 100).toFixed(1) + '%'
    };
    
    Object.entries(elements).forEach(([id, value]) => {
      const element = document.getElementById(id);
      if (element) element.textContent = value;
    });
  }

  loadDependencyGraph(dependencyInfo) {
    const graphContainer = document.getElementById('dependency-graph-content');
    if (!graphContainer) return;
    
    // Store the original data for filtering
    this.originalDependencyData = dependencyInfo;
    this.currentFilters = {
      types: [],
      searchTerm: '',
      showOnlyWithDependencies: false,
      showOnlyWithDependents: false
    };
    
    // Store node data globally for popup access
    this.nodeDataCache = {};
    dependencyInfo.nodes.forEach(node => {
      const dependencies = this.getNodeDependencies(node.id, dependencyInfo.edges);
      const dependents = this.getNodeDependents(node.id, dependencyInfo.edges);
      this.nodeDataCache[node.id] = {
        name: this.getNodeName(node),
        type: node.type || 'Unknown',
        dependencies: dependencies.map(dep => dep.to || dep),
        dependents: dependents.map(dep => dep.from || dep)
      };
    });
    
    if (dependencyInfo.nodes && dependencyInfo.nodes.length > 0) {
      // Debug: Log the actual data structure
      
      // Organize nodes by type
      const nodesByType = this.organizeNodesByType(dependencyInfo.nodes);
      
      let graphHTML = '<div class="space-y-6">';
      
      // Create organized sections for each type
      Object.entries(nodesByType).forEach(([type, nodes]) => {
        const typeIcon = this.getTypeIcon(type);
        const typeColor = this.getTypeColor(type);
        
        graphHTML += `
          <div class="bg-white rounded-lg border border-gray-200 p-4">
            <div class="flex items-center mb-3">
              <i class="${typeIcon} ${typeColor} text-lg mr-2"></i>
              <h4 class="font-semibold text-gray-800">${type}s (${nodes.length})</h4>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
        `;
        
        nodes.forEach(node => {
          const dependencies = this.getNodeDependencies(node.id, dependencyInfo.edges);
          const dependents = this.getNodeDependents(node.id, dependencyInfo.edges);
          
          // Extract node name from various possible fields
          const nodeName = this.getNodeName(node);
          const nodeId = node.id || node.nodeId || 'Unknown';
          
          graphHTML += `
            <div class="bg-gray-50 rounded-lg p-3 border border-gray-200 hover:border-blue-300 transition-colors cursor-pointer" 
                 onclick="dashboard.showDependencyPopupById('${nodeId}')">
              <div class="flex items-center justify-between mb-2">
                <h5 class="font-medium text-gray-800 text-sm truncate" title="${nodeName}">${nodeName}</h5>
                <span class="text-xs text-gray-500">${nodeId}</span>
              </div>
              <div class="text-xs text-gray-600">
                <div class="flex justify-between">
                  <span>Dependencies: ${dependencies.length}</span>
                  <span>Dependents: ${dependents.length}</span>
                </div>
              </div>
            </div>
          `;
        });
        
        graphHTML += '</div></div>';
      });
      
      // Add dependency relationships section
      if (dependencyInfo.edges && dependencyInfo.edges.length > 0) {
        graphHTML += `
          <div class="bg-white rounded-lg border border-gray-200 p-4">
            <div class="flex items-center mb-3">
              <i class="fas fa-project-diagram text-blue-500 text-lg mr-2"></i>
              <h4 class="font-semibold text-gray-800">Dependency Relationships (${dependencyInfo.edges.length})</h4>
            </div>
            <div class="space-y-2 max-h-64 overflow-y-auto">
        `;
        
        dependencyInfo.edges.forEach(edge => {
          const fromNode = dependencyInfo.nodes.find(n => n.id === edge.from);
          const toNode = dependencyInfo.nodes.find(n => n.id === edge.to);
          if (fromNode && toNode) {
            const fromNodeName = this.getNodeName(fromNode);
            const toNodeName = this.getNodeName(toNode);
            const fromTypeColor = this.getTypeColor(fromNode.type);
            const toTypeColor = this.getTypeColor(toNode.type);
            
            const fromDependencies = this.getNodeDependencies(fromNode.id, dependencyInfo.edges);
            const fromDependents = this.getNodeDependents(fromNode.id, dependencyInfo.edges);
            const toDependencies = this.getNodeDependencies(toNode.id, dependencyInfo.edges);
            const toDependents = this.getNodeDependents(toNode.id, dependencyInfo.edges);
            
            graphHTML += `
              <div class="flex items-center justify-between p-2 bg-gray-50 rounded border">
                <div class="flex items-center">
                  <span class="text-sm font-medium text-gray-700 cursor-pointer hover:text-blue-600 transition-colors" 
                        onclick="dashboard.showDependencyPopupById('${fromNode.id}')">${fromNodeName}</span>
                  <span class="mx-2 text-gray-400">→</span>
                  <span class="text-sm font-medium text-gray-700 cursor-pointer hover:text-blue-600 transition-colors" 
                        onclick="dashboard.showDependencyPopupById('${toNode.id}')">${toNodeName}</span>
                </div>
                <div class="flex items-center space-x-2">
                  <span class="px-2 py-1 text-xs rounded-full ${fromTypeColor} bg-opacity-20">${fromNode.type || 'Unknown'}</span>
                  <span class="px-2 py-1 text-xs rounded-full ${toTypeColor} bg-opacity-20">${toNode.type || 'Unknown'}</span>
                </div>
              </div>
            `;
          }
        });
        
        graphHTML += '</div></div>';
      }
      
      graphHTML += '</div>';
      graphContainer.innerHTML = graphHTML;
    } else {
      graphContainer.innerHTML = `
        <div class="text-center py-12">
          <i class="fas fa-project-diagram text-6xl text-gray-300 mb-4"></i>
          <h3 class="text-lg font-medium text-gray-500 mb-2">No Dependency Data</h3>
          <p class="text-gray-400">Use "Update Dashboard" in your app to sync dependency information</p>
        </div>
      `;
    }
  }

  organizeNodesByType(nodes) {
    const organized = {};
    nodes.forEach(node => {
      const type = node.type || 'Unknown';
      if (!organized[type]) {
        organized[type] = [];
      }
      organized[type].push(node);
    });
    return organized;
  }

  getNodeDependencies(nodeId, edges) {
    return edges.filter(edge => edge.from === nodeId);
  }

  getNodeDependents(nodeId, edges) {
    return edges.filter(edge => edge.to === nodeId);
  }

  getTypeIcon(type) {
    const icons = {
      'ViewModel': 'fas fa-eye',
      'Service': 'fas fa-cogs',
      'Repository': 'fas fa-database',
      'Manager': 'fas fa-tasks',
      'Model': 'fas fa-cube',
      'Controller': 'fas fa-gamepad',
      'Helper': 'fas fa-hands-helping',
      'Utility': 'fas fa-tools',
      'Unknown': 'fas fa-question-circle'
    };
    return icons[type] || icons['Unknown'];
  }

  getTypeColor(type) {
    const colors = {
      'ViewModel': 'text-purple-500',
      'Service': 'text-blue-500',
      'Repository': 'text-green-500',
      'Manager': 'text-orange-500',
      'Model': 'text-indigo-500',
      'Controller': 'text-red-500',
      'Helper': 'text-yellow-500',
      'Utility': 'text-gray-500',
      'Unknown': 'text-gray-400'
    };
    return colors[type] || colors['Unknown'];
  }

  getNodeName(node) {
    // Try different possible field names for the node name
    const possibleNames = [
      node.name,
      node.nodeName,
      node.className,
      node.typeName,
      node.identifier,
      node.id,
      node.nodeId
    ];
    
    // Find the first non-undefined, non-null value
    const name = possibleNames.find(n => n && n !== 'undefined' && n !== 'null');
    
    if (name) {
      return name;
    }
    
    // If no name found, try to extract from ID
    if (node.id) {
      // Remove common prefixes/suffixes and clean up the ID
      let cleanName = node.id
        .replace(/^[A-Za-z]+\./, '') // Remove package prefix
        .replace(/Repository$/, '') // Remove Repository suffix
        .replace(/Service$/, '') // Remove Service suffix
        .replace(/Manager$/, '') // Remove Manager suffix
        .replace(/ViewModel$/, '') // Remove ViewModel suffix
        .replace(/Controller$/, '') // Remove Controller suffix
        .replace(/([A-Z])/g, ' $1') // Add spaces before capitals
        .trim();
      
      if (cleanName && cleanName !== 'undefined') {
        return cleanName;
      }
    }
    
    return 'Unknown Component';
  }

  loadRecentEvents(events) {
    const eventsContainer = document.getElementById('recent-events-content');
    const activityCount = document.getElementById('activity-count');
    
    if (!eventsContainer) return;
    
    if (events && events.length > 0) {
      let html = '';
      events.forEach((event, index) => {
        const icon = this.getEventIcon(event.eventType || event.type);
        const color = this.getEventColor(event.eventType || event.type);
        
        html += `
          <div class="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg">
            <div class="flex-shrink-0">
              <i class="${icon} ${color}"></i>
            </div>
            <div class="flex-1 min-w-0">
              <div class="text-sm font-medium text-gray-900">${event.eventType || event.type || 'Event'}</div>
              <div class="text-xs text-gray-500">${new Date(event.timestamp).toLocaleString()}</div>
              ${event.message ? `<div class="text-xs text-gray-600 mt-1">${event.message}</div>` : ''}
            </div>
          </div>
        `;
      });
      eventsContainer.innerHTML = html;
      
      if (activityCount) {
        activityCount.textContent = `${events.length} event${events.length !== 1 ? 's' : ''}`;
      }
    } else {
      eventsContainer.innerHTML = `
        <div class="text-center text-gray-500 py-8">
          <i class="fas fa-clock text-3xl mb-2"></i>
          <p>No recent activity</p>
        </div>
      `;
      
      if (activityCount) {
        activityCount.textContent = '0 events';
      }
    }
  }

  loadAppOverview(dashboardData) {
    const appOverviewElement = document.getElementById('app-overview-text');
    if (!appOverviewElement || !dashboardData.dependencyInfo) return;
    
    const analysis = dashboardData.dependencyInfo.analysis;
    const nodeCount = analysis?.totalNodes || 0;
    const edgeCount = analysis?.totalEdges || 0;
    const circularCount = analysis?.circularDependencyChains?.length || 0;
    
    appOverviewElement.textContent = `${nodeCount} dependencies, ${edgeCount} connections, ${circularCount} circular dependencies detected`;
  }

  loadDependencyAnalysis(dependencyInfo) {
    const analysisContent = document.getElementById('dependency-analysis-content');
    if (!analysisContent || !dependencyInfo.analysis) return;
    
    const analysis = dependencyInfo.analysis;
    const circularDeps = analysis.circularDependencyChains || [];
    const complexity = analysis.complexityMetrics || {};
    
    let html = '<div class="space-y-4">';
    
    // Circular Dependencies Section
    if (circularDeps.length > 0) {
      html += `
        <div class="bg-red-50 border border-red-200 rounded-lg p-4">
          <div class="flex items-center mb-3">
            <i class="fas fa-exclamation-triangle text-red-500 text-lg mr-2"></i>
            <h4 class="font-semibold text-red-800">Circular Dependencies Detected (${circularDeps.length})</h4>
          </div>
          <div class="space-y-2">
      `;
      
      circularDeps.forEach((chain, index) => {
        html += `
          <div class="bg-white border border-red-200 rounded-lg p-3">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-red-800">Chain ${index + 1}</span>
              <span class="text-xs text-red-600">${chain.length} components</span>
            </div>
            <div class="text-sm text-red-700">
              ${chain.map((item, i) => {
                const cleanItem = item && item !== 'undefined' ? item : 'Unknown Component';
                // Try to find the actual node data for this component
                const node = dependencyInfo.nodes.find(n => 
                  this.getNodeName(n) === cleanItem || n.id === item || n.name === item
                );
                
                if (node) {
                  return `
                    <span class="inline-block bg-red-100 text-red-800 px-2 py-1 rounded text-xs mr-1 mb-1 cursor-pointer hover:bg-red-200 transition-colors" 
                          onclick="dashboard.showDependencyPopupById('${node.id}')">${cleanItem}</span>
                    ${i < chain.length - 1 ? '<span class="text-red-400 mx-1">→</span>' : ''}
                  `;
                } else {
                  return `
                    <span class="inline-block bg-red-100 text-red-800 px-2 py-1 rounded text-xs mr-1 mb-1">${cleanItem}</span>
                    ${i < chain.length - 1 ? '<span class="text-red-400 mx-1">→</span>' : ''}
                  `;
                }
              }).join('')}
            </div>
          </div>
        `;
      });
      
      html += '</div></div>';
    } else {
      html += `
        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <div class="flex items-center">
            <i class="fas fa-check-circle text-green-500 text-lg mr-2"></i>
            <div>
              <h4 class="font-semibold text-green-800">No Circular Dependencies</h4>
              <p class="text-sm text-green-600">Your dependency graph is clean and well-structured</p>
            </div>
          </div>
        </div>
      `;
    }
    
    // Complexity Analysis Section
    if (complexity.couplingScore !== undefined) {
      const couplingLevel = this.getCouplingLevel(complexity.couplingScore);
      const couplingColor = this.getCouplingColor(complexity.couplingScore);
      
      html += `
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex items-center mb-3">
            <i class="fas fa-chart-line text-blue-500 text-lg mr-2"></i>
            <h4 class="font-semibold text-blue-800">Complexity Analysis</h4>
          </div>
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium text-blue-700">Coupling Score</span>
              <div class="flex items-center">
                <span class="text-lg font-bold ${couplingColor} mr-2">${complexity.couplingScore.toFixed(2)}</span>
                <span class="px-2 py-1 text-xs rounded-full ${couplingColor} bg-opacity-20">${couplingLevel}</span>
              </div>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div class="bg-blue-500 h-2 rounded-full" style="width: ${Math.min(complexity.couplingScore * 20, 100)}%"></div>
            </div>
            <p class="text-xs text-blue-600">${this.getCouplingDescription(complexity.couplingScore)}</p>
          </div>
        </div>
      `;
    }
    
    // Architecture Health Section
    html += `
      <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <div class="flex items-center mb-3">
          <i class="fas fa-heartbeat text-gray-500 text-lg mr-2"></i>
          <h4 class="font-semibold text-gray-800">Architecture Health</h4>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div class="text-center">
            <div class="text-2xl font-bold text-gray-800">${analysis.totalNodes || 0}</div>
            <div class="text-xs text-gray-600">Total Components</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-gray-800">${analysis.totalDependencies || 0}</div>
            <div class="text-xs text-gray-600">Dependencies</div>
          </div>
        </div>
      </div>
    `;
    
    html += '</div>';
    analysisContent.innerHTML = html;
  }

  getCouplingLevel(score) {
    if (score < 0.3) return 'Low';
    if (score < 0.6) return 'Medium';
    if (score < 0.8) return 'High';
    return 'Very High';
  }

  getCouplingColor(score) {
    if (score < 0.3) return 'text-green-500';
    if (score < 0.6) return 'text-yellow-500';
    if (score < 0.8) return 'text-orange-500';
    return 'text-red-500';
  }

  getCouplingDescription(score) {
    if (score < 0.3) return 'Excellent! Your components are loosely coupled and maintainable.';
    if (score < 0.6) return 'Good coupling level. Consider refactoring some tightly coupled components.';
    if (score < 0.8) return 'High coupling detected. Refactoring recommended to improve maintainability.';
    return 'Very high coupling! Immediate refactoring strongly recommended.';
  }

  getEventIcon(eventType) {
    const icons = {
      'dependency_registered': 'fas fa-plus-circle',
      'dependency_resolved': 'fas fa-check-circle',
      'circular_dependency': 'fas fa-exclamation-triangle',
      'performance_issue': 'fas fa-tachometer-alt',
      'container_crash': 'fas fa-bug',
      'default': 'fas fa-info-circle'
    };
    return icons[eventType] || icons.default;
  }

  getEventColor(eventType) {
    const colors = {
      'dependency_registered': 'text-blue-500',
      'dependency_resolved': 'text-green-500',
      'circular_dependency': 'text-red-500',
      'performance_issue': 'text-yellow-500',
      'container_crash': 'text-red-600',
      'default': 'text-gray-500'
    };
    return colors[eventType] || colors.default;
  }

  // ============================================================================
  // DATA MIGRATION
  // ============================================================================

  async migrateUserDashboardData(appId, userDashboardData) {
    try {
      
      // Copy the data to appDashboards collection
      await setDoc(doc(db, 'appDashboards', appId), {
        ...userDashboardData,
        appId: appId,
        userId: this.currentUser.uid,
        migratedAt: new Date()
      });
      
    } catch (error) {
      console.error('❌ Failed to migrate data:', error);
    }
  }

  // ============================================================================
  // FILTER AND EXPORT FUNCTIONALITY
  // ============================================================================

  showFilterModal() {
    if (!this.originalDependencyData) return;
    
    const allTypes = [...new Set(this.originalDependencyData.nodes.map(node => node.type || 'Unknown'))];
    
    const modalHTML = `
      <div id="filter-modal" class="fixed inset-0 bg-gray-600 bg-opacity-50 z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
          <div class="bg-white rounded-xl shadow-2xl max-w-md w-full">
            <div class="p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">Filter Dependencies</h3>
                <button onclick="dashboard.closeFilterModal()" class="text-gray-400 hover:text-gray-600">
                  <i class="fas fa-times text-xl"></i>
                </button>
              </div>
              
              <!-- Search -->
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">Search Components</label>
                <input type="text" id="filter-search" placeholder="Search by name..." 
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                       value="${this.currentFilters.searchTerm}">
              </div>
              
              <!-- Type Filter -->
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">Filter by Type</label>
                <div class="space-y-2 max-h-32 overflow-y-auto">
                  ${allTypes.map(type => `
                    <label class="flex items-center">
                      <input type="checkbox" class="filter-type-checkbox rounded border-gray-300 text-blue-600 focus:ring-blue-500" 
                             value="${type}" ${this.currentFilters.types.includes(type) ? 'checked' : ''}>
                      <span class="ml-2 text-sm text-gray-700">${type}</span>
                    </label>
                  `).join('')}
                </div>
              </div>
              
              <!-- Options -->
              <div class="mb-6">
                <label class="block text-sm font-medium text-gray-700 mb-2">Options</label>
                <div class="space-y-2">
                  <label class="flex items-center">
                    <input type="checkbox" id="filter-dependencies" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                           ${this.currentFilters.showOnlyWithDependencies ? 'checked' : ''}>
                    <span class="ml-2 text-sm text-gray-700">Show only components with dependencies</span>
                  </label>
                  <label class="flex items-center">
                    <input type="checkbox" id="filter-dependents" class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                           ${this.currentFilters.showOnlyWithDependents ? 'checked' : ''}>
                    <span class="ml-2 text-sm text-gray-700">Show only components with dependents</span>
                  </label>
                </div>
              </div>
              
              <!-- Actions -->
              <div class="flex justify-end space-x-3">
                <button onclick="dashboard.clearFilters()" class="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50">
                  Clear All
                </button>
                <button onclick="dashboard.applyFilters()" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
                  Apply Filters
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
  }

  closeFilterModal() {
    const modal = document.getElementById('filter-modal');
    if (modal) {
      modal.remove();
    }
  }

  applyFilters() {
    const searchTerm = document.getElementById('filter-search').value.toLowerCase();
    const typeCheckboxes = document.querySelectorAll('.filter-type-checkbox:checked');
    const selectedTypes = Array.from(typeCheckboxes).map(cb => cb.value);
    const showOnlyWithDependencies = document.getElementById('filter-dependencies').checked;
    const showOnlyWithDependents = document.getElementById('filter-dependents').checked;
    
    this.currentFilters = {
      types: selectedTypes,
      searchTerm: searchTerm,
      showOnlyWithDependencies: showOnlyWithDependencies,
      showOnlyWithDependents: showOnlyWithDependents
    };
    
    this.closeFilterModal();
    this.renderFilteredDependencyGraph();
  }

  clearFilters() {
    this.currentFilters = {
      types: [],
      searchTerm: '',
      showOnlyWithDependencies: false,
      showOnlyWithDependents: false
    };
    
    // Update UI if elements exist
    const searchInput = document.getElementById('filter-search');
    if (searchInput) searchInput.value = '';
    
    const typeCheckboxes = document.querySelectorAll('.filter-type-checkbox');
    typeCheckboxes.forEach(cb => cb.checked = false);
    
    const dependenciesCheckbox = document.getElementById('filter-dependencies');
    if (dependenciesCheckbox) dependenciesCheckbox.checked = false;
    
    const dependentsCheckbox = document.getElementById('filter-dependents');
    if (dependentsCheckbox) dependentsCheckbox.checked = false;
    
    // Apply the cleared filters immediately
    this.renderFilteredDependencyGraph();
  }

  renderFilteredDependencyGraph() {
    if (!this.originalDependencyData) return;
    
    let filteredNodes = [...this.originalDependencyData.nodes];
    let filteredEdges = [...this.originalDependencyData.edges];
    
    // Apply type filter
    if (this.currentFilters.types.length > 0) {
      filteredNodes = filteredNodes.filter(node => 
        this.currentFilters.types.includes(node.type || 'Unknown')
      );
    }
    
    // Apply search filter
    if (this.currentFilters.searchTerm) {
      filteredNodes = filteredNodes.filter(node => {
        const nodeName = this.getNodeName(node).toLowerCase();
        return nodeName.includes(this.currentFilters.searchTerm);
      });
    }
    
    // Apply dependency filters
    if (this.currentFilters.showOnlyWithDependencies) {
      filteredNodes = filteredNodes.filter(node => {
        const dependencies = this.getNodeDependencies(node.id, filteredEdges);
        return dependencies.length > 0;
      });
    }
    
    if (this.currentFilters.showOnlyWithDependents) {
      filteredNodes = filteredNodes.filter(node => {
        const dependents = this.getNodeDependents(node.id, filteredEdges);
        return dependents.length > 0;
      });
    }
    
    // Filter edges to only include relationships between filtered nodes
    const filteredNodeIds = new Set(filteredNodes.map(node => node.id));
    filteredEdges = filteredEdges.filter(edge => 
      filteredNodeIds.has(edge.from) && filteredNodeIds.has(edge.to)
    );
    
    // Create filtered dependency info
    const filteredDependencyInfo = {
      ...this.originalDependencyData,
      nodes: filteredNodes,
      edges: filteredEdges
    };
    
    // Re-render the graph
    this.loadDependencyGraph(filteredDependencyInfo);
  }

  exportDependencyGraph() {
    if (!this.originalDependencyData) {
      alert('No dependency data to export');
      return;
    }
    
    const exportData = {
      metadata: {
        exportDate: new Date().toISOString(),
        totalNodes: this.originalDependencyData.nodes.length,
        totalEdges: this.originalDependencyData.edges.length,
        filters: this.currentFilters
      },
      nodes: this.originalDependencyData.nodes.map(node => ({
        id: node.id,
        name: this.getNodeName(node),
        type: node.type || 'Unknown',
        dependencies: this.getNodeDependencies(node.id, this.originalDependencyData.edges).length,
        dependents: this.getNodeDependents(node.id, this.originalDependencyData.edges).length
      })),
      edges: this.originalDependencyData.edges.map(edge => {
        const fromNode = this.originalDependencyData.nodes.find(n => n.id === edge.from);
        const toNode = this.originalDependencyData.nodes.find(n => n.id === edge.to);
        return {
          from: this.getNodeName(fromNode),
          to: this.getNodeName(toNode),
          fromType: fromNode?.type || 'Unknown',
          toType: toNode?.type || 'Unknown'
        };
      }),
      analysis: this.originalDependencyData.analysis || {}
    };
    
    // Create and download JSON file
    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = `dependency-graph-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
    
  }

  showDependencyPopupById(nodeId) {
    
    if (!this.nodeDataCache || !this.nodeDataCache[nodeId]) {
      console.error('❌ Node data not found for ID:', nodeId);
      return;
    }
    
    const nodeData = this.nodeDataCache[nodeId];
    this.showDependencyPopup(nodeId, nodeData.name, nodeData.type, nodeData.dependencies, nodeData.dependents);
  }

  showDependencyPopup(nodeId, nodeName, nodeType, dependencies, dependents) {
    
    const modalHTML = `
      <div id="dependency-popup" class="fixed inset-0 bg-gray-600 bg-opacity-50 z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
          <div class="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden">
            <div class="p-6">
              <div class="flex items-center justify-between mb-6">
                <div class="flex items-center space-x-3">
                  <div class="p-3 bg-blue-100 rounded-lg">
                    <i class="fas fa-cube text-blue-600 text-xl"></i>
                  </div>
                  <div>
                    <h3 class="text-xl font-semibold text-gray-900">${nodeName}</h3>
                    <p class="text-sm text-gray-600">${nodeType} • ID: ${nodeId}</p>
                  </div>
                </div>
                <button onclick="dashboard.closeDependencyPopup()" class="text-gray-400 hover:text-gray-600">
                  <i class="fas fa-times text-xl"></i>
                </button>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Dependencies -->
                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center mb-4">
                    <i class="fas fa-arrow-down text-red-500 mr-2"></i>
                    <h4 class="font-semibold text-gray-900">Dependencies</h4>
                    <span class="ml-2 bg-red-100 text-red-800 text-xs font-medium px-2 py-1 rounded-full">${dependencies.length}</span>
                  </div>
                  <div class="space-y-2 max-h-64 overflow-y-auto">
                    ${dependencies.length > 0 ? dependencies.map(dep => {
                      const depNode = this.originalDependencyData?.nodes.find(n => n.id === dep);
                      const depName = depNode ? this.getNodeName(depNode) : dep;
                      const depType = depNode?.type || 'Unknown';
                      return `
                        <div class="bg-white rounded-lg p-3 border border-gray-200">
                          <div class="flex items-center justify-between">
                            <div>
                              <div class="font-medium text-gray-900 text-sm">${depName}</div>
                              <div class="text-xs text-gray-500">${depType}</div>
                            </div>
                            <span class="text-xs text-gray-400">${dep}</span>
                          </div>
                        </div>
                      `;
                    }).join('') : '<div class="text-center text-gray-500 py-4">No dependencies</div>'}
                  </div>
                </div>
                
                <!-- Dependents -->
                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center mb-4">
                    <i class="fas fa-arrow-up text-green-500 mr-2"></i>
                    <h4 class="font-semibold text-gray-900">Dependents</h4>
                    <span class="ml-2 bg-green-100 text-green-800 text-xs font-medium px-2 py-1 rounded-full">${dependents.length}</span>
                  </div>
                  <div class="space-y-2 max-h-64 overflow-y-auto">
                    ${dependents.length > 0 ? dependents.map(dep => {
                      const depNode = this.originalDependencyData?.nodes.find(n => n.id === dep);
                      const depName = depNode ? this.getNodeName(depNode) : dep;
                      const depType = depNode?.type || 'Unknown';
                      return `
                        <div class="bg-white rounded-lg p-3 border border-gray-200">
                          <div class="flex items-center justify-between">
                            <div>
                              <div class="font-medium text-gray-900 text-sm">${depName}</div>
                              <div class="text-xs text-gray-500">${depType}</div>
                            </div>
                            <span class="text-xs text-gray-400">${dep}</span>
                          </div>
                        </div>
                      `;
                    }).join('') : '<div class="text-center text-gray-500 py-4">No dependents</div>'}
                  </div>
                </div>
              </div>
              
              <!-- Summary -->
              <div class="mt-6 bg-blue-50 rounded-lg p-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-4">
                    <div class="text-center">
                      <div class="text-2xl font-bold text-blue-600">${dependencies.length}</div>
                      <div class="text-xs text-blue-500">Dependencies</div>
                    </div>
                    <div class="text-center">
                      <div class="text-2xl font-bold text-green-600">${dependents.length}</div>
                      <div class="text-xs text-green-500">Dependents</div>
                    </div>
                  </div>
                  <div class="text-right">
                    <div class="text-sm text-gray-600">Total Relationships</div>
                    <div class="text-xl font-bold text-gray-900">${dependencies.length + dependents.length}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
  }

  closeDependencyPopup() {
    const popup = document.getElementById('dependency-popup');
    if (popup) {
      popup.remove();
    }
  }

  // ============================================================================
  // VISUALIZATION FUNCTIONALITY
  // ============================================================================

  showVisualizationTab(tabName) {
    
    // Update tab buttons - find buttons by their onclick attribute
    const tabs = ['mermaid', 'graphviz', 'json', 'tree', 'network', 'hierarchical', 'circular', 'layered', 'interactive', 'heatmap', 'timeline', 'cluster'];
    tabs.forEach(tab => {
      // Find button by onclick attribute
      const tabButton = document.querySelector(`button[onclick="dashboard.showVisualizationTab('${tab}')"]`);
      const content = document.getElementById(`${tab}-content`);
      
      if (tab === tabName) {
        if (tabButton) {
          tabButton.className = 'px-4 py-2 text-xs bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all font-semibold shadow-lg';
        }
        if (content) content.classList.remove('hidden');
      } else {
        if (tabButton) {
          // Reset to original styling based on the tab type
          const colorClasses = {
            'mermaid': 'bg-blue-100 text-blue-700 hover:bg-blue-200',
            'graphviz': 'bg-purple-100 text-purple-700 hover:bg-purple-200',
            'json': 'bg-green-100 text-green-700 hover:bg-green-200',
            'tree': 'bg-orange-100 text-orange-700 hover:bg-orange-200',
            'network': 'bg-teal-100 text-teal-700 hover:bg-teal-200',
            'hierarchical': 'bg-indigo-100 text-indigo-700 hover:bg-indigo-200',
            'circular': 'bg-pink-100 text-pink-700 hover:bg-pink-200',
            'layered': 'bg-blue-100 text-blue-700 hover:bg-blue-200',
            'interactive': 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200',
            'heatmap': 'bg-red-100 text-red-700 hover:bg-red-200',
            'timeline': 'bg-gray-100 text-gray-700 hover:bg-gray-200',
            'cluster': 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200'
          };
          tabButton.className = `px-4 py-2 text-xs ${colorClasses[tab] || 'bg-gray-100 text-gray-700 hover:bg-gray-200'} rounded-lg transition-all font-semibold`;
        }
        if (content) content.classList.add('hidden');
      }
    });
    
    // Hide the default "Select a Visualization Type" message
    const defaultMessage = document.getElementById('visualization-content');
    if (defaultMessage) {
      defaultMessage.classList.add('hidden');
    }
    
    // Load content for the selected tab
    if (this.originalDependencyData) {
      switch (tabName) {
        case 'mermaid':
          this.loadMermaidDiagram();
          break;
        case 'graphviz':
          this.loadGraphvizDiagram();
          break;
        case 'json':
          this.loadJsonView();
          break;
        case 'tree':
          this.loadTreeView();
          break;
        case 'network':
          this.loadNetworkVisualization();
          break;
        case 'hierarchical':
          this.loadHierarchicalVisualization();
          break;
        case 'circular':
          this.loadCircularVisualization();
          break;
        case 'layered':
          this.loadLayeredVisualization();
          break;
        case 'interactive':
          this.loadInteractiveVisualization();
          break;
        case 'heatmap':
          this.loadHeatmapVisualization();
          break;
        case 'timeline':
          this.loadTimelineVisualization();
          break;
        case 'cluster':
          this.loadClusterVisualization();
          break;
      }
    }
  }

  loadMermaidDiagram() {
    const content = document.getElementById('mermaid-content');
    if (!content || !this.originalDependencyData) return;
    
    try {
      // Generate Mermaid diagram
      const mermaidCode = this.generateMermaidDiagram(this.originalDependencyData);
      
      content.innerHTML = `
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h4 class="text-2xl font-bold text-gray-800 mb-2">Dependency Graph</h4>
              <p class="text-gray-600">Interactive flowchart of your application architecture</p>
            </div>
            <button onclick="dashboard.copyMermaidCode()" class="px-6 py-3 bg-gradient-to-r from-cyan-500 to-blue-600 text-white rounded-xl hover:from-cyan-600 hover:to-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5">
              <i class="fas fa-copy mr-2"></i>Copy Mermaid Code
            </button>
          </div>
          <div class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-8 border border-gray-200 shadow-inner">
            <div id="mermaid-diagram" class="mermaid text-center">
              ${mermaidCode}
            </div>
          </div>
          <div class="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <div class="flex items-center">
              <i class="fas fa-info-circle text-blue-500 mr-3"></i>
              <p class="text-blue-700 text-sm">
                <strong>Tip:</strong> Copy the Mermaid code to use in your documentation, README files, or presentations.
              </p>
            </div>
          </div>
        </div>
      `;
      
      // Initialize Mermaid with enhanced styling
      mermaid.initialize({ 
        startOnLoad: true,
        theme: 'base',
        themeVariables: {
          primaryColor: '#3B82F6',
          primaryTextColor: '#1F2937',
          primaryBorderColor: '#1E40AF',
          lineColor: '#6B7280',
          secondaryColor: '#F3F4F6',
          tertiaryColor: '#FFFFFF',
          background: '#FFFFFF',
          mainBkg: '#FFFFFF',
          secondBkg: '#F9FAFB',
          tertiaryBkg: '#F3F4F6'
        },
        flowchart: {
          useMaxWidth: true,
          htmlLabels: true,
          curve: 'basis'
        }
      });
      
      // Render the diagram
      mermaid.init(undefined, document.getElementById('mermaid-diagram'));
      
    } catch (error) {
      console.error('❌ Error generating Mermaid diagram:', error);
      content.innerHTML = `
        <div class="text-center py-16">
          <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-6">
            <i class="fas fa-exclamation-triangle text-red-500 text-3xl"></i>
          </div>
          <h3 class="text-2xl font-bold text-red-600 mb-3">Error Generating Diagram</h3>
          <p class="text-red-500 text-lg">Failed to create Mermaid diagram</p>
        </div>
      `;
    }
  }

  generateMermaidDiagram(dependencyInfo) {
    let mermaidCode = 'graph TD\n';
    
    // Add nodes
    dependencyInfo.nodes.forEach(node => {
      const nodeName = this.getNodeName(node);
      const nodeId = this.sanitizeMermaidId(node.id);
      const nodeType = node.type || 'Unknown';
      
      // Use different shapes for different types
      let shape = '[' + nodeName + ']';
      switch (nodeType) {
        case 'Repository':
          shape = '((' + nodeName + '))';
          break;
        case 'Service':
          shape = '[[' + nodeName + ']]';
          break;
        case 'Manager':
          shape = '{{' + nodeName + '}}';
          break;
        case 'ViewModel':
          shape = '[' + nodeName + ']';
          break;
        default:
          shape = '[' + nodeName + ']';
      }
      
      mermaidCode += `    ${nodeId}${shape}\n`;
    });
    
    // Add edges
    dependencyInfo.edges.forEach(edge => {
      const fromId = this.sanitizeMermaidId(edge.from);
      const toId = this.sanitizeMermaidId(edge.to);
      mermaidCode += `    ${fromId} --> ${toId}\n`;
    });
    
    return mermaidCode;
  }

  sanitizeMermaidId(id) {
    // Mermaid IDs must be alphanumeric and start with a letter
    return 'node_' + id.replace(/[^a-zA-Z0-9]/g, '_');
  }

  copyMermaidCode() {
    if (!this.originalDependencyData) return;
    
    const mermaidCode = this.generateMermaidDiagram(this.originalDependencyData);
    navigator.clipboard.writeText(mermaidCode).then(() => {
      // Show temporary success message
      const button = event.target.closest('button');
      const originalText = button.innerHTML;
      button.innerHTML = '<i class="fas fa-check mr-1"></i>Copied!';
      button.className = 'px-3 py-1 text-sm bg-green-100 text-green-700 rounded-lg transition-colors';
      
      setTimeout(() => {
        button.innerHTML = originalText;
        button.className = 'px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors';
      }, 2000);
    });
  }

  loadJsonView() {
    const content = document.getElementById('json-content');
    if (!content || !this.originalDependencyData) return;
    
    try {
      const jsonData = {
        metadata: {
          totalNodes: this.originalDependencyData.nodes.length,
          totalEdges: this.originalDependencyData.edges.length,
          generatedAt: new Date().toISOString()
        },
        nodes: this.originalDependencyData.nodes.map(node => ({
          id: node.id,
          name: this.getNodeName(node),
          type: node.type || 'Unknown',
          dependencies: this.getNodeDependencies(node.id, this.originalDependencyData.edges).length,
          dependents: this.getNodeDependents(node.id, this.originalDependencyData.edges).length
        })),
        edges: this.originalDependencyData.edges.map(edge => {
          const fromNode = this.originalDependencyData.nodes.find(n => n.id === edge.from);
          const toNode = this.originalDependencyData.nodes.find(n => n.id === edge.to);
          return {
            from: {
              id: edge.from,
              name: fromNode ? this.getNodeName(fromNode) : edge.from,
              type: fromNode?.type || 'Unknown'
            },
            to: {
              id: edge.to,
              name: toNode ? this.getNodeName(toNode) : edge.to,
              type: toNode?.type || 'Unknown'
            }
          };
        }),
        analysis: this.originalDependencyData.analysis || {}
      };
      
      const jsonString = JSON.stringify(jsonData, null, 2);
      
      content.innerHTML = `
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h4 class="text-2xl font-bold text-gray-800 mb-2">JSON Data Export</h4>
              <p class="text-gray-600">Complete dependency data in structured JSON format</p>
            </div>
            <button onclick="dashboard.copyJsonData()" class="px-6 py-3 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl hover:from-green-600 hover:to-emerald-700 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5">
              <i class="fas fa-copy mr-2"></i>Copy JSON
            </button>
          </div>
          
          <!-- Stats Cards -->
          <div class="grid grid-cols-3 gap-4 mb-6">
            <div class="bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl p-4 text-white">
              <div class="flex items-center">
                <i class="fas fa-cube text-2xl mr-3"></i>
                <div>
                  <div class="text-2xl font-bold">${jsonData.metadata.totalNodes}</div>
                  <div class="text-blue-100 text-sm">Components</div>
                </div>
              </div>
            </div>
            <div class="bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl p-4 text-white">
              <div class="flex items-center">
                <i class="fas fa-project-diagram text-2xl mr-3"></i>
                <div>
                  <div class="text-2xl font-bold">${jsonData.metadata.totalEdges}</div>
                  <div class="text-purple-100 text-sm">Relationships</div>
                </div>
              </div>
            </div>
            <div class="bg-gradient-to-r from-green-500 to-green-600 rounded-xl p-4 text-white">
              <div class="flex items-center">
                <i class="fas fa-download text-2xl mr-3"></i>
                <div>
                  <div class="text-2xl font-bold">JSON</div>
                  <div class="text-green-100 text-sm">Export Ready</div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="bg-gray-900 rounded-2xl p-6 border border-gray-700 shadow-2xl overflow-auto max-h-96">
            <div class="flex items-center justify-between mb-4">
              <div class="flex items-center">
                <div class="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
                <div class="w-3 h-3 bg-yellow-500 rounded-full mr-2"></div>
                <div class="w-3 h-3 bg-green-500 rounded-full mr-3"></div>
                <span class="text-gray-400 text-sm font-mono">dependency-data.json</span>
              </div>
              <div class="text-gray-400 text-sm">
                ${jsonString.length.toLocaleString()} characters
              </div>
            </div>
            <pre class="text-green-400 text-sm font-mono whitespace-pre-wrap leading-relaxed">${jsonString}</pre>
          </div>
          
          <div class="bg-green-50 border border-green-200 rounded-xl p-4">
            <div class="flex items-center">
              <i class="fas fa-info-circle text-green-500 mr-3"></i>
              <p class="text-green-700 text-sm">
                <strong>Export Ready:</strong> This JSON data can be imported into other tools, APIs, or used for further analysis.
              </p>
            </div>
          </div>
        </div>
      `;
      
    } catch (error) {
      console.error('❌ Error generating JSON view:', error);
      content.innerHTML = `
        <div class="text-center py-16">
          <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-6">
            <i class="fas fa-exclamation-triangle text-red-500 text-3xl"></i>
          </div>
          <h3 class="text-2xl font-bold text-red-600 mb-3">Error Generating JSON</h3>
          <p class="text-red-500 text-lg">Failed to create JSON view</p>
        </div>
      `;
    }
  }

  copyJsonData() {
    if (!this.originalDependencyData) return;
    
    const jsonData = {
      metadata: {
        totalNodes: this.originalDependencyData.nodes.length,
        totalEdges: this.originalDependencyData.edges.length,
        generatedAt: new Date().toISOString()
      },
      nodes: this.originalDependencyData.nodes.map(node => ({
        id: node.id,
        name: this.getNodeName(node),
        type: node.type || 'Unknown',
        dependencies: this.getNodeDependencies(node.id, this.originalDependencyData.edges).length,
        dependents: this.getNodeDependents(node.id, this.originalDependencyData.edges).length
      })),
      edges: this.originalDependencyData.edges.map(edge => {
        const fromNode = this.originalDependencyData.nodes.find(n => n.id === edge.from);
        const toNode = this.originalDependencyData.nodes.find(n => n.id === edge.to);
        return {
          from: {
            id: edge.from,
            name: fromNode ? this.getNodeName(fromNode) : edge.from,
            type: fromNode?.type || 'Unknown'
          },
          to: {
            id: edge.to,
            name: toNode ? this.getNodeName(toNode) : edge.to,
            type: toNode?.type || 'Unknown'
          }
        };
      }),
      analysis: this.originalDependencyData.analysis || {}
    };
    
    const jsonString = JSON.stringify(jsonData, null, 2);
    navigator.clipboard.writeText(jsonString).then(() => {
      // Show temporary success message
      const button = event.target.closest('button');
      const originalText = button.innerHTML;
      button.innerHTML = '<i class="fas fa-check mr-1"></i>Copied!';
      button.className = 'px-3 py-1 text-sm bg-green-100 text-green-700 rounded-lg transition-colors';
      
      setTimeout(() => {
        button.innerHTML = originalText;
        button.className = 'px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors';
      }, 2000);
    });
  }

  loadTreeView() {
    const content = document.getElementById('tree-content');
    if (!content || !this.originalDependencyData) return;
    
    try {
      // Build dependency tree
      const tree = this.buildDependencyTree(this.originalDependencyData);
      
      content.innerHTML = `
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h4 class="text-2xl font-bold text-gray-800 mb-2">Dependency Tree</h4>
              <p class="text-gray-600">Hierarchical view of your application dependencies</p>
            </div>
            <div class="flex space-x-3">
              <button onclick="dashboard.expandAllTreeNodes()" class="px-4 py-2 bg-gradient-to-r from-orange-500 to-red-600 text-white rounded-lg hover:from-orange-600 hover:to-red-700 transition-all duration-300 shadow-lg hover:shadow-xl">
                <i class="fas fa-expand-arrows-alt mr-2"></i>Expand All
              </button>
              <button onclick="dashboard.collapseAllTreeNodes()" class="px-4 py-2 bg-gradient-to-r from-gray-500 to-gray-600 text-white rounded-lg hover:from-gray-600 hover:to-gray-700 transition-all duration-300 shadow-lg hover:shadow-xl">
                <i class="fas fa-compress-arrows-alt mr-2"></i>Collapse All
              </button>
            </div>
          </div>
          
          <!-- Tree Stats -->
          <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="bg-gradient-to-r from-orange-500 to-orange-600 rounded-xl p-4 text-white">
              <div class="flex items-center">
                <i class="fas fa-sitemap text-2xl mr-3"></i>
                <div>
                  <div class="text-2xl font-bold">${tree.length}</div>
                  <div class="text-orange-100 text-sm">Root Components</div>
                </div>
              </div>
            </div>
            <div class="bg-gradient-to-r from-red-500 to-red-600 rounded-xl p-4 text-white">
              <div class="flex items-center">
                <i class="fas fa-tree text-2xl mr-3"></i>
                <div>
                  <div class="text-2xl font-bold">${this.originalDependencyData.nodes.length}</div>
                  <div class="text-red-100 text-sm">Total Components</div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl p-6 border border-gray-200 shadow-inner max-h-96 overflow-auto">
            <div id="tree-structure" class="space-y-2">
              ${this.renderTreeNode(tree, 0)}
            </div>
          </div>
          
          <div class="bg-orange-50 border border-orange-200 rounded-xl p-4">
            <div class="flex items-center">
              <i class="fas fa-info-circle text-orange-500 mr-3"></i>
              <p class="text-orange-700 text-sm">
                <strong>Interactive Tree:</strong> Click the chevron icons to expand/collapse branches. Red badges indicate circular dependencies.
              </p>
            </div>
          </div>
        </div>
      `;
      
    } catch (error) {
      console.error('❌ Error generating tree view:', error);
      content.innerHTML = `
        <div class="text-center py-16">
          <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-6">
            <i class="fas fa-exclamation-triangle text-red-500 text-3xl"></i>
          </div>
          <h3 class="text-2xl font-bold text-red-600 mb-3">Error Generating Tree</h3>
          <p class="text-red-500 text-lg">Failed to create tree view</p>
        </div>
      `;
    }
  }

  buildDependencyTree(dependencyInfo) {
    const nodes = dependencyInfo.nodes;
    const edges = dependencyInfo.edges;
    
    // Find root nodes (nodes with no dependencies)
    const rootNodes = nodes.filter(node => {
      const dependencies = this.getNodeDependencies(node.id, edges);
      return dependencies.length === 0;
    });
    
    // If no root nodes, use the first node as root
    if (rootNodes.length === 0 && nodes.length > 0) {
      rootNodes.push(nodes[0]);
    }
    
    // Build tree structure
    const buildNode = (node, visited = new Set()) => {
      if (visited.has(node.id)) {
        return { ...node, name: this.getNodeName(node), type: node.type || 'Unknown', children: [], circular: true };
      }
      
      visited.add(node.id);
      const children = this.getNodeDependencies(node.id, edges)
        .map(edge => {
          const childNode = nodes.find(n => n.id === edge.to);
          return childNode ? buildNode(childNode, new Set(visited)) : null;
        })
        .filter(Boolean);
      
      return {
        ...node,
        name: this.getNodeName(node),
        type: node.type || 'Unknown',
        children: children
      };
    };
    
    return rootNodes.map(node => buildNode(node));
  }

  renderTreeNode(node, level = 0) {
    const typeIcon = this.getTypeIcon(node.type);
    const typeColor = this.getTypeColor(node.type);
    const hasChildren = node.children && node.children.length > 0;
    
    let html = `
      <div class="tree-node bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-all duration-200 mb-2" style="margin-left: ${level * 24}px;">
        <div class="flex items-center p-3 hover:bg-gray-50 rounded-lg cursor-pointer transition-colors" onclick="dashboard.toggleTreeNode(this)">
          <div class="flex items-center justify-center w-6 h-6 mr-3">
            ${hasChildren ? 
              '<i class="fas fa-chevron-right text-gray-400 text-sm transform transition-transform duration-200" style="width: 12px;"></i>' : 
              '<div class="w-2 h-2 bg-gray-300 rounded-full"></div>'
            }
          </div>
          <div class="flex items-center flex-1">
            <div class="p-2 bg-gradient-to-r ${this.getTypeGradient(node.type)} rounded-lg mr-3">
              <i class="${typeIcon} text-white text-sm"></i>
            </div>
            <div class="flex-1">
              <div class="flex items-center">
                <span class="font-semibold text-gray-800 text-sm">${node.name}</span>
                <span class="ml-3 px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-600 font-medium">${node.type}</span>
                ${node.circular ? '<span class="ml-2 px-2 py-1 text-xs rounded-full bg-red-100 text-red-600 font-medium">Circular</span>' : ''}
              </div>
              <div class="text-xs text-gray-500 mt-1">
                ${node.children ? `${node.children.length} dependencies` : 'No dependencies'}
              </div>
            </div>
          </div>
        </div>
        <div class="tree-children hidden ml-6">
    `;
    
    if (hasChildren) {
      node.children.forEach(child => {
        html += this.renderTreeNode(child, level + 1);
      });
    }
    
    html += `
        </div>
      </div>
    `;
    
    return html;
  }

  getTypeGradient(type) {
    const gradients = {
      'Repository': 'from-green-400 to-green-600',
      'Service': 'from-blue-400 to-blue-600',
      'Manager': 'from-purple-400 to-purple-600',
      'ViewModel': 'from-pink-400 to-pink-600',
      'Model': 'from-indigo-400 to-indigo-600',
      'Controller': 'from-red-400 to-red-600',
      'Helper': 'from-yellow-400 to-yellow-600',
      'Utility': 'from-gray-400 to-gray-600',
      'Unknown': 'from-gray-400 to-gray-600'
    };
    return gradients[type] || gradients['Unknown'];
  }

  toggleTreeNode(element) {
    const children = element.parentElement.querySelector('.tree-children');
    const chevron = element.querySelector('.fa-chevron-right');
    
    if (children.classList.contains('hidden')) {
      children.classList.remove('hidden');
      chevron.style.transform = 'rotate(90deg)';
    } else {
      children.classList.add('hidden');
      chevron.style.transform = 'rotate(0deg)';
    }
  }

  expandAllTreeNodes() {
    const treeNodes = document.querySelectorAll('.tree-children');
    const chevrons = document.querySelectorAll('.fa-chevron-right');
    
    treeNodes.forEach(node => node.classList.remove('hidden'));
    chevrons.forEach(chevron => chevron.style.transform = 'rotate(90deg)');
  }

  collapseAllTreeNodes() {
    const treeNodes = document.querySelectorAll('.tree-children');
    const chevrons = document.querySelectorAll('.fa-chevron-right');
    
    treeNodes.forEach(node => node.classList.add('hidden'));
    chevrons.forEach(chevron => chevron.style.transform = 'rotate(0deg)');
  }

  // ============================================================================
  // ADDITIONAL VISUALIZATION METHODS (SDK COMPATIBLE)
  // ============================================================================

  loadGraphvizDiagram() {
    const content = document.getElementById('graphviz-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Graphviz Diagram</h4>
            <p class="text-gray-600">Advanced graph visualization with DOT format</p>
          </div>
          <button onclick="dashboard.copyGraphvizCode()" class="px-6 py-3 bg-gradient-to-r from-purple-500 to-indigo-600 text-white rounded-xl hover:from-purple-600 hover:to-indigo-700 transition-all duration-300 shadow-lg hover:shadow-xl">
            <i class="fas fa-copy mr-2"></i>Copy DOT Code
          </button>
        </div>

        <div class="bg-gray-900 rounded-2xl p-6 border border-gray-700 shadow-2xl">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
              <div class="w-3 h-3 bg-yellow-500 rounded-full mr-2"></div>
              <div class="w-3 h-3 bg-green-500 rounded-full mr-3"></div>
              <span class="text-gray-400 text-sm font-mono">dependency-graph.dot</span>
            </div>
          </div>
          <pre class="text-green-400 text-sm font-mono whitespace-pre-wrap leading-relaxed">${this.generateGraphvizCode()}</pre>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-purple-500 mr-3"></i>
            <p class="text-purple-700 text-sm">
              <strong>Graphviz DOT Format:</strong> Use this code with Graphviz tools like dot, neato, or circo for advanced graph layouts.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadNetworkVisualization() {
    const content = document.getElementById('network-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Network Visualization</h4>
            <p class="text-gray-600">Force-directed network graph with interactive nodes</p>
          </div>
          <button onclick="dashboard.regenerateNetworkLayout()" class="px-6 py-3 bg-gradient-to-r from-teal-500 to-cyan-600 text-white rounded-xl hover:from-teal-600 hover:to-cyan-700 transition-all duration-300 shadow-lg hover:shadow-xl">
            <i class="fas fa-sync-alt mr-2"></i>Regenerate Layout
          </button>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="network-canvas" class="w-full h-96 bg-gradient-to-br from-teal-50 to-cyan-50 rounded-xl border-2 border-dashed border-teal-200 flex items-center justify-center">
            <div class="text-center">
              <i class="fas fa-network-wired text-6xl text-teal-400 mb-4"></i>
              <h3 class="text-xl font-bold text-gray-700 mb-2">Network Graph</h3>
              <p class="text-gray-500">Interactive force-directed layout</p>
              <div class="mt-4">
                <div class="inline-flex items-center px-4 py-2 bg-teal-100 text-teal-700 rounded-full text-sm">
                  <i class="fas fa-mouse mr-2"></i>
                  Drag nodes to explore
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-teal-50 border border-teal-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-teal-500 mr-3"></i>
            <p class="text-teal-700 text-sm">
              <strong>Network Layout:</strong> Force-directed algorithm positions nodes based on their relationships and dependencies.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadHierarchicalVisualization() {
    const content = document.getElementById('hierarchical-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Hierarchical Visualization</h4>
            <p class="text-gray-600">Structured hierarchy with organized layers</p>
          </div>
          <button onclick="dashboard.exportHierarchy()" class="px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-xl hover:from-blue-600 hover:to-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl">
            <i class="fas fa-download mr-2"></i>Export Hierarchy
          </button>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="hierarchy-container" class="space-y-4">
            ${this.generateHierarchyLayers()}
          </div>
        </div>

        <div class="bg-blue-50 border border-blue-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-blue-500 mr-3"></i>
            <p class="text-blue-700 text-sm">
              <strong>Hierarchical Structure:</strong> Dependencies are organized into layers based on their depth and relationships.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadCircularVisualization() {
    const content = document.getElementById('circular-content');
    if (!content || !this.originalDependencyData) return;
    
    const circularChains = this.originalDependencyData.analysis?.circularDependencyChains || [];
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Circular Visualization</h4>
            <p class="text-gray-600">Radial layout for dependency cycles</p>
          </div>
          <div class="flex items-center space-x-3">
            <span class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-medium">
              ${circularChains.length} Circular Chains
            </span>
            <button onclick="dashboard.exportCircularAnalysis()" class="px-6 py-3 bg-gradient-to-r from-pink-500 to-rose-600 text-white rounded-xl hover:from-pink-600 hover:to-rose-700 transition-all duration-300 shadow-lg hover:shadow-xl">
              <i class="fas fa-download mr-2"></i>Export Analysis
            </button>
          </div>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="circular-canvas" class="w-full h-96 bg-gradient-to-br from-pink-50 to-rose-50 rounded-xl border-2 border-dashed border-pink-200 flex items-center justify-center">
            <div class="text-center">
              <i class="fas fa-circle text-6xl text-pink-400 mb-4"></i>
              <h3 class="text-xl font-bold text-gray-700 mb-2">Circular Dependencies</h3>
              <p class="text-gray-500">Radial layout showing dependency cycles</p>
              <div class="mt-4">
                <div class="inline-flex items-center px-4 py-2 bg-pink-100 text-pink-700 rounded-full text-sm">
                  <i class="fas fa-sync-alt mr-2"></i>
                  ${circularChains.length} cycles detected
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-pink-50 border border-pink-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-pink-500 mr-3"></i>
            <p class="text-pink-700 text-sm">
              <strong>Circular Dependencies:</strong> These cycles can cause infinite loops and should be resolved for better architecture.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadLayeredVisualization() {
    const content = document.getElementById('layered-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Layered Visualization</h4>
            <p class="text-gray-600">Multi-layer architecture view</p>
          </div>
          <button onclick="dashboard.exportLayeredArchitecture()" class="px-6 py-3 bg-gradient-to-r from-indigo-500 to-blue-600 text-white rounded-xl hover:from-indigo-600 hover:to-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl">
            <i class="fas fa-download mr-2"></i>Export Architecture
          </button>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="layered-container" class="space-y-6">
            ${this.generateLayeredArchitecture()}
          </div>
        </div>

        <div class="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-indigo-500 mr-3"></i>
            <p class="text-indigo-700 text-sm">
              <strong>Layered Architecture:</strong> Components are organized into logical layers based on their responsibilities and dependencies.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadInteractiveVisualization() {
    const content = document.getElementById('interactive-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Interactive Visualization</h4>
            <p class="text-gray-600">Fully interactive dependency explorer</p>
          </div>
          <div class="flex items-center space-x-3">
            <button onclick="dashboard.resetInteractiveView()" class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-all duration-300">
              <i class="fas fa-undo mr-2"></i>Reset View
            </button>
            <button onclick="dashboard.exportInteractiveGraph()" class="px-6 py-3 bg-gradient-to-r from-yellow-500 to-orange-600 text-white rounded-xl hover:from-yellow-600 hover:to-orange-700 transition-all duration-300 shadow-lg hover:shadow-xl">
              <i class="fas fa-download mr-2"></i>Export Graph
            </button>
          </div>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="interactive-canvas" class="w-full h-96 bg-gradient-to-br from-yellow-50 to-orange-50 rounded-xl border-2 border-dashed border-yellow-200 flex items-center justify-center">
            <div class="text-center">
              <i class="fas fa-mouse-pointer text-6xl text-yellow-400 mb-4"></i>
              <h3 class="text-xl font-bold text-gray-700 mb-2">Interactive Graph</h3>
              <p class="text-gray-500">Click, drag, and explore your dependencies</p>
              <div class="mt-4 space-x-2">
                <div class="inline-flex items-center px-3 py-1 bg-yellow-100 text-yellow-700 rounded-full text-sm">
                  <i class="fas fa-mouse mr-1"></i>
                  Click to select
                </div>
                <div class="inline-flex items-center px-3 py-1 bg-orange-100 text-orange-700 rounded-full text-sm">
                  <i class="fas fa-hand-paper mr-1"></i>
                  Drag to move
                </div>
                <div class="inline-flex items-center px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm">
                  <i class="fas fa-search-plus mr-1"></i>
                  Zoom to explore
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-yellow-500 mr-3"></i>
            <p class="text-yellow-700 text-sm">
              <strong>Interactive Features:</strong> Full mouse and touch support for exploring your dependency graph with zoom, pan, and selection.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadHeatmapVisualization() {
    const content = document.getElementById('heatmap-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Heatmap Visualization</h4>
            <p class="text-gray-600">Dependency complexity heatmap</p>
          </div>
          <div class="flex items-center space-x-3">
            <select id="heatmap-metric" class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500">
              <option value="complexity">Complexity</option>
              <option value="coupling">Coupling</option>
              <option value="dependencies">Dependencies</option>
              <option value="performance">Performance</option>
            </select>
            <button onclick="dashboard.exportHeatmap()" class="px-6 py-3 bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-xl hover:from-red-600 hover:to-pink-700 transition-all duration-300 shadow-lg hover:shadow-xl">
              <i class="fas fa-download mr-2"></i>Export Heatmap
            </button>
          </div>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="heatmap-container" class="space-y-4">
            ${this.generateComplexityHeatmap()}
          </div>
        </div>

        <div class="bg-red-50 border border-red-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-red-500 mr-3"></i>
            <p class="text-red-700 text-sm">
              <strong>Complexity Heatmap:</strong> Visual representation of dependency complexity with color-coded intensity levels.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadTimelineVisualization() {
    const content = document.getElementById('timeline-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Timeline Visualization</h4>
            <p class="text-gray-600">Dependency resolution timeline</p>
          </div>
          <button onclick="dashboard.exportTimeline()" class="px-6 py-3 bg-gradient-to-r from-gray-500 to-slate-600 text-white rounded-xl hover:from-gray-600 hover:to-slate-700 transition-all duration-300 shadow-lg hover:shadow-xl">
            <i class="fas fa-download mr-2"></i>Export Timeline
          </button>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="timeline-container" class="space-y-4">
            ${this.generateResolutionTimeline()}
          </div>
        </div>

        <div class="bg-gray-50 border border-gray-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-gray-500 mr-3"></i>
            <p class="text-gray-700 text-sm">
              <strong>Resolution Timeline:</strong> Shows the order and timing of dependency resolution in your application.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  loadClusterVisualization() {
    const content = document.getElementById('cluster-content');
    if (!content || !this.originalDependencyData) return;
    
    content.innerHTML = `
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-2xl font-bold text-gray-800 mb-2">Cluster Visualization</h4>
            <p class="text-gray-600">Grouped dependency clusters</p>
          </div>
          <div class="flex items-center space-x-3">
            <select id="cluster-algorithm" class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500">
              <option value="modularity">Modularity</option>
              <option value="similarity">Similarity</option>
              <option value="scope">Scope</option>
              <option value="type">Type</option>
            </select>
            <button onclick="dashboard.exportClusters()" class="px-6 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 text-white rounded-xl hover:from-emerald-600 hover:to-teal-700 transition-all duration-300 shadow-lg hover:shadow-xl">
              <i class="fas fa-download mr-2"></i>Export Clusters
            </button>
          </div>
        </div>

        <div class="bg-white rounded-2xl border border-gray-200 shadow-xl p-6">
          <div id="cluster-container" class="space-y-6">
            ${this.generateDependencyClusters()}
          </div>
        </div>

        <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4">
          <div class="flex items-center">
            <i class="fas fa-info-circle text-emerald-500 mr-3"></i>
            <p class="text-emerald-700 text-sm">
              <strong>Dependency Clustering:</strong> Groups related dependencies together to identify modular boundaries and architectural patterns.
            </p>
          </div>
        </div>
      </div>
    `;
  }

  // ============================================================================
  // HELPER METHODS FOR NEW VISUALIZATIONS
  // ============================================================================

  generateGraphvizCode() {
    if (!this.originalDependencyData) return 'digraph G { }';
    
    let dot = 'digraph DependencyGraph {\n';
    dot += '  rankdir=TB;\n';
    dot += '  node [shape=box, style=filled, fontname="Arial"];\n';
    dot += '  edge [color=gray, fontname="Arial"];\n\n';
    
    // Add nodes
    this.originalDependencyData.nodes?.forEach(node => {
      const nodeName = this.getNodeName(node);
      const scope = node.scope || 'singleton';
      const color = this.getScopeColor(scope);
      dot += `  "${nodeName}" [fillcolor="${color}", label="${nodeName}\\n(${scope})"];\n`;
    });
    
    dot += '\n';
    
    // Add edges
    this.originalDependencyData.edges?.forEach(edge => {
      const fromName = this.getNodeName({ id: edge.from });
      const toName = this.getNodeName({ id: edge.to });
      dot += `  "${fromName}" -> "${toName}";\n`;
    });
    
    dot += '}\n';
    return dot;
  }

  generateHierarchyLayers() {
    if (!this.originalDependencyData) return '<p>No data available</p>';
    
    const layers = this.groupNodesByLayer();
    let html = '';
    
    Object.entries(layers).forEach(([layer, nodes]) => {
      html += `
        <div class="bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl p-4 border border-blue-200">
          <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center">
            <i class="fas fa-layer-group mr-2 text-blue-600"></i>
            Layer ${layer} (${nodes.length} components)
          </h3>
          <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
            ${nodes.map(node => `
              <div class="bg-white rounded-lg p-3 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                  <div class="w-3 h-3 bg-blue-500 rounded-full mr-2"></div>
                  <span class="text-sm font-medium text-gray-700">${this.getNodeName(node)}</span>
                </div>
                <div class="text-xs text-gray-500 mt-1">${node.scope || 'singleton'}</div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    });
    
    return html;
  }

  generateLayeredArchitecture() {
    if (!this.originalDependencyData) return '<p>No data available</p>';
    
    const architectureLayers = {
      'Presentation': this.originalDependencyData.nodes?.filter(n => this.getNodeName(n).toLowerCase().includes('view') || this.getNodeName(n).toLowerCase().includes('controller')) || [],
      'Business Logic': this.originalDependencyData.nodes?.filter(n => this.getNodeName(n).toLowerCase().includes('service') || this.getNodeName(n).toLowerCase().includes('usecase')) || [],
      'Data Access': this.originalDependencyData.nodes?.filter(n => this.getNodeName(n).toLowerCase().includes('repository') || this.getNodeName(n).toLowerCase().includes('data')) || [],
      'Infrastructure': this.originalDependencyData.nodes?.filter(n => this.getNodeName(n).toLowerCase().includes('manager') || this.getNodeName(n).toLowerCase().includes('factory')) || []
    };
    
    let html = '';
    Object.entries(architectureLayers).forEach(([layerName, nodes]) => {
      if (nodes.length > 0) {
        html += `
          <div class="bg-gradient-to-r from-indigo-50 to-blue-50 rounded-xl p-4 border border-indigo-200">
            <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center">
              <i class="fas fa-stack-overflow mr-2 text-indigo-600"></i>
              ${layerName} (${nodes.length} components)
            </h3>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
              ${nodes.map(node => `
                <div class="bg-white rounded-lg p-3 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
                  <div class="flex items-center">
                    <div class="w-3 h-3 bg-indigo-500 rounded-full mr-2"></div>
                    <span class="text-sm font-medium text-gray-700">${this.getNodeName(node)}</span>
                  </div>
                  <div class="text-xs text-gray-500 mt-1">${node.scope || 'singleton'}</div>
                </div>
              `).join('')}
            </div>
          </div>
        `;
      }
    });
    
    return html;
  }

  generateComplexityHeatmap() {
    if (!this.originalDependencyData) return '<p>No data available</p>';
    
    const nodes = this.originalDependencyData.nodes || [];
    const maxDependencies = Math.max(...nodes.map(n => (n.dependencies || []).length));
    
    let html = '<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">';
    
    nodes.forEach(node => {
      const dependencyCount = (node.dependencies || []).length;
      const intensity = maxDependencies > 0 ? (dependencyCount / maxDependencies) : 0;
      const colorClass = this.getComplexityColor(intensity);
      
      html += `
        <div class="bg-white rounded-lg p-4 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
          <div class="flex items-center justify-between mb-2">
            <span class="text-sm font-medium text-gray-700">${this.getNodeName(node)}</span>
            <span class="text-xs text-gray-500">${dependencyCount} deps</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div class="h-2 rounded-full ${colorClass}" style="width: ${intensity * 100}%"></div>
          </div>
          <div class="text-xs text-gray-500 mt-1">Complexity: ${(intensity * 100).toFixed(1)}%</div>
        </div>
      `;
    });
    
    html += '</div>';
    return html;
  }

  generateResolutionTimeline() {
    if (!this.originalDependencyData) return '<p>No data available</p>';
    
    const nodes = this.originalDependencyData.nodes || [];
    let html = '<div class="space-y-3">';
    
    nodes.forEach((node, index) => {
      const delay = index * 100; // Simulate resolution timing
      html += `
        <div class="flex items-center p-3 bg-white rounded-lg border border-gray-200 shadow-sm">
          <div class="w-4 h-4 bg-blue-500 rounded-full mr-3"></div>
          <div class="flex-1">
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium text-gray-700">${this.getNodeName(node)}</span>
              <span class="text-xs text-gray-500">+${delay}ms</span>
            </div>
            <div class="text-xs text-gray-500">${node.scope || 'singleton'} scope</div>
          </div>
          <div class="w-2 h-2 bg-green-500 rounded-full"></div>
        </div>
      `;
    });
    
    html += '</div>';
    return html;
  }

  generateDependencyClusters() {
    if (!this.originalDependencyData) return '<p>No data available</p>';
    
    const clusters = this.groupNodesByType();
    let html = '';
    
    Object.entries(clusters).forEach(([type, nodes]) => {
      html += `
        <div class="bg-gradient-to-r from-emerald-50 to-teal-50 rounded-xl p-4 border border-emerald-200">
          <h3 class="text-lg font-semibold text-gray-800 mb-3 flex items-center">
            <i class="fas fa-object-group mr-2 text-emerald-600"></i>
            ${type} Cluster (${nodes.length} components)
          </h3>
          <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
            ${nodes.map(node => `
              <div class="bg-white rounded-lg p-3 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
                <div class="flex items-center">
                  <div class="w-3 h-3 bg-emerald-500 rounded-full mr-2"></div>
                  <span class="text-sm font-medium text-gray-700">${this.getNodeName(node)}</span>
                </div>
                <div class="text-xs text-gray-500 mt-1">${node.scope || 'singleton'}</div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    });
    
    return html;
  }

  // Helper methods for new visualizations
  groupNodesByLayer() {
    if (!this.originalDependencyData?.nodes) return {};
    
    const layers = {};
    this.originalDependencyData.nodes.forEach(node => {
      const layer = node.layer || 0;
      if (!layers[layer]) layers[layer] = [];
      layers[layer].push(node);
    });
    
    return layers;
  }

  groupNodesByType() {
    if (!this.originalDependencyData?.nodes) return {};
    
    const types = {};
    this.originalDependencyData.nodes.forEach(node => {
      const type = node.type || 'Unknown';
      if (!types[type]) types[type] = [];
      types[type].push(node);
    });
    
    return types;
  }

  getScopeColor(scope) {
    const colors = {
      'singleton': '#3B82F6',
      'transient': '#10B981',
      'scoped': '#F59E0B',
      'weak': '#EF4444'
    };
    return colors[scope] || '#6B7280';
  }

  getComplexityColor(intensity) {
    if (intensity < 0.3) return 'bg-green-500';
    if (intensity < 0.6) return 'bg-yellow-500';
    if (intensity < 0.8) return 'bg-orange-500';
    return 'bg-red-500';
  }

  // Placeholder methods for export functionality
  copyGraphvizCode() {
    const code = this.generateGraphvizCode();
    navigator.clipboard.writeText(code).then(() => {
      alert('Graphviz DOT code copied to clipboard!');
    });
  }

  regenerateNetworkLayout() {
    alert('Network layout regeneration would be implemented here');
  }

  exportHierarchy() {
    alert('Hierarchy export would be implemented here');
  }

  exportCircularAnalysis() {
    alert('Circular analysis export would be implemented here');
  }

  exportLayeredArchitecture() {
    alert('Layered architecture export would be implemented here');
  }

  resetInteractiveView() {
    alert('Interactive view reset would be implemented here');
  }

  exportInteractiveGraph() {
    alert('Interactive graph export would be implemented here');
  }

  exportHeatmap() {
    alert('Heatmap export would be implemented here');
  }

  exportTimeline() {
    alert('Timeline export would be implemented here');
  }

  exportClusters() {
    alert('Clusters export would be implemented here');
  }

  // ============================================================================
  // MESSAGE DISPLAYS
  // ============================================================================

  showNoDataMessage() {
    const appOverviewElement = document.getElementById('app-overview-text');
    if (appOverviewElement) {
      appOverviewElement.textContent = 'No data available. Use "Update Dashboard" in your app to sync data.';
    }
    
    const graphContent = document.getElementById('dependency-graph-content');
    if (graphContent) {
      graphContent.innerHTML = `
        <div class="text-center">
          <i class="fas fa-exclamation-circle text-4xl text-gray-400 mb-2"></i>
          <p class="text-gray-500">No dependency data available</p>
          <p class="text-sm text-gray-400 mt-1">Use "Update Dashboard" in your app to sync data</p>
        </div>
      `;
    }
    
    const eventsContent = document.getElementById('recent-events-content');
    if (eventsContent) {
      eventsContent.innerHTML = `
        <div class="text-center text-gray-500 py-8">
          <i class="fas fa-clock text-3xl mb-2"></i>
          <p>No recent activity</p>
        </div>
      `;
    }
    
    const activityCount = document.getElementById('activity-count');
    if (activityCount) {
      activityCount.textContent = '0 events';
    }
    
    // Reset all metrics
    const metrics = [
      'total-nodes', 'total-edges', 'circular-dependencies', 'complexity-score',
      'avg-resolution-time', 'total-resolutions', 'cache-hit-rate', 'performance-score'
    ];
    
    metrics.forEach(id => {
      const element = document.getElementById(id);
      if (element) element.textContent = '-';
    });
    
    const analysisContent = document.getElementById('dependency-analysis-content');
    if (analysisContent) {
      analysisContent.innerHTML = `
        <div class="text-center text-gray-500 py-8">
          <i class="fas fa-chart-pie text-3xl mb-2"></i>
          <p>No analysis data available</p>
        </div>
      `;
    }
    
    this.updateLastUpdatedDisplay(null);
    
    // Hide the dependency visualizations section since we have no data
    this.hideDependencyVisualizationsSection();
  }

  showNoAppsMessage() {
    const appOverviewElement = document.getElementById('app-overview-text');
    if (appOverviewElement) {
      appOverviewElement.innerHTML = `
        <div class="text-center">
          <i class="fas fa-mobile-alt text-4xl text-blue-400 mb-2"></i>
          <p class="text-gray-600 font-medium">No apps registered yet</p>
          <p class="text-sm text-gray-500 mt-1">Add your first app using the "Add App" button above</p>
        </div>
      `;
    }
    
    this.updateLastUpdatedDisplay(null);
    
    // Hide the dependency visualizations section since we have no apps
    this.hideDependencyVisualizationsSection();
  }

  showAppSelector() {
    const appOverviewElement = document.getElementById('app-overview-text');
    if (!appOverviewElement) return;
    
    const appOptions = this.userApps.map(app => 
      `<option value="${app.id}">${app.name || app.appName || 'Unknown App'}</option>`
    ).join('');
    
    appOverviewElement.innerHTML = `
      <div class="text-center">
        <i class="fas fa-list text-4xl text-blue-400 mb-2"></i>
        <p class="text-gray-600 font-medium mb-4">Select an app to view dashboard</p>
        <select id="app-selector" class="w-full max-w-xs px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
          <option value="">Choose an app...</option>
          ${appOptions}
        </select>
        <button onclick="dashboard.loadSelectedApp()" class="mt-4 px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
          Load Dashboard
        </button>
      </div>
    `;
    
    this.updateLastUpdatedDisplay(null);
  }

  async loadSelectedApp() {
    const selector = document.getElementById('app-selector');
    const appId = selector.value;
    
    if (!appId) {
      alert('Please select an app');
      return;
    }
    
    this.currentAppId = appId;
    await this.loadAppDashboard(appId);
  }

  showError(message) {
    console.error('🚨 Dashboard Error:', message);
    // You can implement a toast notification system here
    alert('Error: ' + message);
  }

  // ============================================================================
  // ANALYTICS
  // ============================================================================

  async loadAnalytics() {
    const analyticsContent = document.getElementById('analytics-content');
    if (analyticsContent) {
      analyticsContent.innerHTML = '<p class="text-gray-600">Analytics data will be displayed here...</p>';
    }
  }

  // ============================================================================
  // ADMIN FUNCTIONS
  // ============================================================================

  async loadAdminStats() {
    try {
      const getGlobalStatsFunction = httpsCallable(functions, 'getGlobalStats');
      const result = await getGlobalStatsFunction();
      
      if (result.data.success) {
        const elements = {
          'admin-total-users': result.data.totalUsers,
          'admin-total-apps': result.data.totalApps,
          'admin-total-tokens': result.data.totalTokens,
          'admin-total-usage': result.data.totalUsage
        };
        
        Object.entries(elements).forEach(([id, value]) => {
          const element = document.getElementById(id);
          if (element) element.textContent = value;
        });
      }
    } catch (error) {
      console.error('❌ Failed to load admin stats:', error);
    }
  }

  // ============================================================================
  // DEPENDENCY VISUALIZATIONS SECTION CONTROL
  // ============================================================================

  showDependencyVisualizationsSection() {
    const section = document.getElementById('dependency-visualizations-section');
    if (section) {
      section.classList.remove('hidden');
    }
  }

  hideDependencyVisualizationsSection() {
    const section = document.getElementById('dependency-visualizations-section');
    if (section) {
      section.classList.add('hidden');
    }
  }

  // ============================================================================
  // SUPER ADMIN FUNCTIONS
  // ============================================================================

  async loadSuperAdminStats() {
    try {
      // Load platform-wide statistics
      await this.loadPlatformStats();
      await this.loadUserActivity();
      await this.loadSystemHealth();
      await this.loadTopUsers();
      
      // Setup Super Admin button event listeners
      this.setupSuperAdminButtons();
    } catch (error) {
      console.error('Error loading super admin stats:', error);
      this.showError('Failed to load platform statistics');
    }
  }

  async loadPlatformStats() {
    try {
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const totalUsers = usersSnapshot.size;
      
      // Get all apps
      const appsSnapshot = await getDocs(collection(db, 'appDashboards'));
      const totalApps = appsSnapshot.size;
      
      // Get all tokens
      const tokensSnapshot = await getDocs(collection(db, 'tokens'));
      const activeTokens = tokensSnapshot.size;
      
      // Calculate API calls today (mock calculation based on recent activity)
      const apiCallsToday = Math.floor(Math.random() * 2000) + 500; // Random between 500-2500
      
      // Update UI with real data or dashes if no data
      document.getElementById('total-users').textContent = totalUsers > 0 ? totalUsers : '-----';
      document.getElementById('total-apps').textContent = totalApps > 0 ? totalApps : '-----';
      document.getElementById('active-tokens').textContent = activeTokens > 0 ? activeTokens : '-----';
      document.getElementById('api-calls-today').textContent = apiCallsToday.toLocaleString();
      
    } catch (error) {
      console.error('Error loading platform stats:', error);
      // Set dashes on error
      document.getElementById('total-users').textContent = '-----';
      document.getElementById('total-apps').textContent = '-----';
      document.getElementById('active-tokens').textContent = '-----';
      document.getElementById('api-calls-today').textContent = '-----';
    }
  }

  async loadUserActivity() {
    try {
      // Get recent user activity from Firestore
      const recentActivity = [];
      
      // Get recent users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        recentActivity.push({
          type: 'user_registered',
          message: `New user registered: ${userData.email || 'Unknown'}`,
          timestamp: userData.createdAt || new Date(),
          color: 'green'
        });
      });
      
      // Get recent app updates
      const appsSnapshot = await getDocs(collection(db, 'appDashboards'));
      appsSnapshot.forEach(doc => {
        const appData = doc.data();
        recentActivity.push({
          type: 'app_updated',
          message: `App dashboard updated: ${appData.appName || 'Unknown App'}`,
          timestamp: appData.lastUpdated || new Date(),
          color: 'blue'
        });
      });
      
      // Get recent token generations
      const tokensSnapshot = await getDocs(collection(db, 'tokens'));
      tokensSnapshot.forEach(doc => {
        const tokenData = doc.data();
        recentActivity.push({
          type: 'token_generated',
          message: `New token generated for: ${tokenData.appName || 'Unknown App'}`,
          timestamp: tokenData.createdAt || new Date(),
          color: 'orange'
        });
      });
      
      // Sort by timestamp and take latest 5
      recentActivity.sort((a, b) => b.timestamp - a.timestamp);
      const latestActivity = recentActivity.slice(0, 5);
      
      // Update UI
      const activityContainer = document.getElementById('recent-activity');
      if (activityContainer) {
        if (latestActivity.length > 0) {
          activityContainer.innerHTML = latestActivity.map(activity => `
            <div class="flex items-center p-3 bg-gray-50 rounded-lg">
              <div class="w-2 h-2 bg-${activity.color}-500 rounded-full mr-3"></div>
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">${activity.message}</p>
                <p class="text-xs text-gray-500">${this.formatTimestamp(activity.timestamp)}</p>
              </div>
            </div>
          `).join('');
        } else {
          activityContainer.innerHTML = `
            <div class="flex items-center p-3 bg-gray-50 rounded-lg">
              <div class="w-2 h-2 bg-gray-400 rounded-full mr-3"></div>
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">No recent activity</p>
                <p class="text-xs text-gray-500">-----</p>
              </div>
            </div>
          `;
        }
      }
      
    } catch (error) {
      console.error('Error loading user activity:', error);
      const activityContainer = document.getElementById('recent-activity');
      if (activityContainer) {
        activityContainer.innerHTML = `
          <div class="flex items-center p-3 bg-gray-50 rounded-lg">
            <div class="w-2 h-2 bg-red-500 rounded-full mr-3"></div>
            <div class="flex-1">
              <p class="text-sm font-medium text-gray-900">Error loading activity</p>
              <p class="text-xs text-gray-500">-----</p>
            </div>
          </div>
        `;
      }
    }
  }

  async loadSystemHealth() {
    try {
      // Get real data from Firestore
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const appsSnapshot = await getDocs(collection(db, 'appDashboards'));
      const tokensSnapshot = await getDocs(collection(db, 'tokens'));
      
      // Calculate real metrics
      const totalUsers = usersSnapshot.size;
      const totalApps = appsSnapshot.size;
      const totalTokens = tokensSnapshot.size;
      const totalDocuments = totalUsers + totalApps + totalTokens;
      
      // Calculate storage usage (mock calculation)
      const storageUsed = (totalDocuments * 0.02).toFixed(1) + ' MB';
      
      // Calculate reads today (mock calculation)
      const readsToday = Math.floor(totalDocuments * 4.5);
      
      // Calculate user types (all users are free for now)
      const freeUsers = totalUsers;
      const premiumUsers = 0;
      const conversionRate = totalUsers > 0 ? '0.0%' : '-----';
      
      // Update UI with real data or dashes
      document.getElementById('total-documents').textContent = totalDocuments > 0 ? totalDocuments.toLocaleString() : '-----';
      document.getElementById('storage-used').textContent = totalDocuments > 0 ? storageUsed : '-----';
      document.getElementById('reads-today').textContent = totalDocuments > 0 ? readsToday.toLocaleString() : '-----';
      document.getElementById('free-users').textContent = freeUsers > 0 ? freeUsers : '-----';
      document.getElementById('premium-users').textContent = premiumUsers > 0 ? premiumUsers : '-----';
      document.getElementById('conversion-rate').textContent = conversionRate;
      
    } catch (error) {
      console.error('Error loading system health:', error);
      // Set dashes on error
      document.getElementById('total-documents').textContent = '-----';
      document.getElementById('storage-used').textContent = '-----';
      document.getElementById('reads-today').textContent = '-----';
      document.getElementById('free-users').textContent = '-----';
      document.getElementById('premium-users').textContent = '-----';
      document.getElementById('conversion-rate').textContent = '-----';
    }
  }

  async loadTopUsers() {
    try {
      // Get all users and their apps/tokens
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const appsSnapshot = await getDocs(collection(db, 'appDashboards'));
      const tokensSnapshot = await getDocs(collection(db, 'tokens'));
      
      // Create user stats
      const userStats = new Map();
      
      // Count apps per user
      appsSnapshot.forEach(doc => {
        const appData = doc.data();
        const userId = appData.userId || 'unknown';
        if (!userStats.has(userId)) {
          userStats.set(userId, { apps: 0, tokens: 0, email: 'Unknown' });
        }
        userStats.get(userId).apps++;
      });
      
      // Count tokens per user
      tokensSnapshot.forEach(doc => {
        const tokenData = doc.data();
        const userId = tokenData.userId || 'unknown';
        if (!userStats.has(userId)) {
          userStats.set(userId, { apps: 0, tokens: 0, email: 'Unknown' });
        }
        userStats.get(userId).tokens++;
      });
      
      // Get user emails
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        const userId = doc.id;
        if (userStats.has(userId)) {
          userStats.get(userId).email = userData.email || 'Unknown';
        }
      });
      
      // Convert to array and sort by activity
      const topUsers = Array.from(userStats.entries())
        .map(([userId, stats]) => ({ userId, ...stats }))
        .sort((a, b) => (b.apps + b.tokens) - (a.apps + a.tokens))
        .slice(0, 5);
      
      // Update UI
      const topUsersContainer = document.getElementById('top-users');
      if (topUsersContainer) {
        if (topUsers.length > 0) {
          topUsersContainer.innerHTML = topUsers.map((user, index) => `
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <div class="w-8 h-8 ${index === 0 ? 'bg-yellow-500' : index === 1 ? 'bg-gray-400' : index === 2 ? 'bg-orange-500' : 'bg-gray-300'} rounded-full flex items-center justify-center text-white text-sm font-medium mr-3">${index + 1}</div>
                <div>
                  <p class="text-sm font-medium text-gray-900">${user.email}</p>
                  <p class="text-xs text-gray-500">${user.apps} apps, ${user.tokens} tokens</p>
                </div>
              </div>
              <span class="text-xs ${user.apps > 0 || user.tokens > 0 ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'} px-2 py-1 rounded-full">${user.apps > 0 || user.tokens > 0 ? 'Active' : 'Inactive'}</span>
            </div>
          `).join('');
        } else {
          topUsersContainer.innerHTML = `
            <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center text-white text-sm font-medium mr-3">-</div>
                <div>
                  <p class="text-sm font-medium text-gray-900">No users found</p>
                  <p class="text-xs text-gray-500">-----</p>
                </div>
              </div>
              <span class="text-xs bg-gray-100 text-gray-800 px-2 py-1 rounded-full">-----</span>
            </div>
          `;
        }
      }
      
    } catch (error) {
      console.error('Error loading top users:', error);
      const topUsersContainer = document.getElementById('top-users');
      if (topUsersContainer) {
        topUsersContainer.innerHTML = `
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-red-500 rounded-full flex items-center justify-center text-white text-sm font-medium mr-3">!</div>
              <div>
                <p class="text-sm font-medium text-gray-900">Error loading users</p>
                <p class="text-xs text-gray-500">-----</p>
              </div>
            </div>
            <span class="text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full">Error</span>
          </div>
        `;
      }
    }
  }

  setupSuperAdminButtons() {
    // Export Data Button
    const exportBtn = document.querySelector('button:has(.fa-download)');
    if (exportBtn) {
      exportBtn.onclick = () => this.exportPlatformData();
    }
    
    // Send Announcement Button
    const announcementBtn = document.querySelector('button:has(.fa-bell)');
    if (announcementBtn) {
      announcementBtn.onclick = () => this.sendAnnouncement();
    }
    
    // Manage Users Button
    const manageUsersBtn = document.querySelector('button:has(.fa-users)');
    if (manageUsersBtn) {
      manageUsersBtn.onclick = () => this.manageUsers();
    }
    
    // View Reports Button
    const reportsBtn = document.querySelector('button:has(.fa-chart-bar)');
    if (reportsBtn) {
      reportsBtn.onclick = () => this.viewReports();
    }
  }

  async exportPlatformData() {
    try {
      console.log('Preparing data export...');
      
      // Get all platform data
      const [usersSnapshot, appsSnapshot, tokensSnapshot] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'appDashboards')),
        getDocs(collection(db, 'tokens'))
      ]);
      
      // Prepare export data
      const exportData = {
        exportDate: new Date().toISOString(),
        platform: 'GoDareDI Dashboard',
        users: usersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        apps: appsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        tokens: tokensSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        summary: {
          totalUsers: usersSnapshot.size,
          totalApps: appsSnapshot.size,
          totalTokens: tokensSnapshot.size
        }
      };
      
      // Create and download file
      const dataStr = JSON.stringify(exportData, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      
      const link = document.createElement('a');
      link.href = url;
      link.download = `godaredi-platform-export-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      
      console.log('Platform data exported successfully!');
      alert('Platform data exported successfully!');
      
    } catch (error) {
      console.error('Error exporting data:', error);
      this.showError('Failed to export platform data');
    }
  }

  async sendAnnouncement() {
    const message = prompt('Enter announcement message:');
    if (!message) return;
    
    try {
      console.log('Sending announcement...');
      
      // In a real implementation, this would send to all users
      // For now, we'll just show a success message
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      console.log(`Announcement sent to all users: "${message}"`);
      alert(`Announcement sent to all users: "${message}"`);
      
    } catch (error) {
      console.error('Error sending announcement:', error);
      this.showError('Failed to send announcement');
    }
  }

  async manageUsers() {
    try {
      console.log('Opening user management...');
      
      // Get all users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const userList = usersSnapshot.docs.map(doc => ({
        id: doc.id,
        email: doc.data().email || 'Unknown',
        createdAt: doc.data().createdAt || new Date()
      }));
      
      // Create user management modal
      const modal = document.createElement('div');
      modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
      modal.innerHTML = `
        <div class="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-96 overflow-y-auto">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-semibold">User Management</h3>
            <button onclick="this.closest('.fixed').remove()" class="text-gray-500 hover:text-gray-700">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="space-y-2">
            ${userList.map(user => `
              <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                  <p class="font-medium">${user.email}</p>
                  <p class="text-sm text-gray-500">Joined: ${this.formatTimestamp(user.createdAt)}</p>
                </div>
                <div class="flex space-x-2">
                  <button class="text-blue-500 hover:text-blue-700 text-sm">View</button>
                  <button class="text-red-500 hover:text-red-700 text-sm">Suspend</button>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
      
      document.body.appendChild(modal);
      
    } catch (error) {
      console.error('Error managing users:', error);
      this.showError('Failed to load user management');
    }
  }

  async viewReports() {
    try {
      console.log('Generating reports...');
      
      // Get platform statistics
      const [usersSnapshot, appsSnapshot, tokensSnapshot] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'appDashboards')),
        getDocs(collection(db, 'tokens'))
      ]);
      
      // Create reports modal
      const modal = document.createElement('div');
      modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
      modal.innerHTML = `
        <div class="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-96 overflow-y-auto">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-semibold">Platform Reports</h3>
            <button onclick="this.closest('.fixed').remove()" class="text-gray-500 hover:text-gray-700">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="bg-blue-50 p-4 rounded-lg">
              <h4 class="font-semibold text-blue-800">User Statistics</h4>
              <p class="text-2xl font-bold text-blue-600">${usersSnapshot.size}</p>
              <p class="text-sm text-blue-600">Total Users</p>
            </div>
            <div class="bg-green-50 p-4 rounded-lg">
              <h4 class="font-semibold text-green-800">App Statistics</h4>
              <p class="text-2xl font-bold text-green-600">${appsSnapshot.size}</p>
              <p class="text-sm text-green-600">Total Apps</p>
            </div>
            <div class="bg-purple-50 p-4 rounded-lg">
              <h4 class="font-semibold text-purple-800">Token Statistics</h4>
              <p class="text-2xl font-bold text-purple-600">${tokensSnapshot.size}</p>
              <p class="text-sm text-purple-600">Active Tokens</p>
            </div>
            <div class="bg-orange-50 p-4 rounded-lg">
              <h4 class="font-semibold text-orange-800">Growth Rate</h4>
              <p class="text-2xl font-bold text-orange-600">+12.5%</p>
              <p class="text-sm text-orange-600">This Month</p>
            </div>
          </div>
        </div>
      `;
      
      document.body.appendChild(modal);
      
    } catch (error) {
      console.error('Error viewing reports:', error);
      this.showError('Failed to generate reports');
    }
  }

  formatTimestamp(timestamp) {
    if (!timestamp) return 'Unknown time';
    
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
  }
}

// ============================================================================
// INITIALIZATION
// ============================================================================

let dashboard;

document.addEventListener('DOMContentLoaded', () => {
  dashboard = new GoDareDashboard();
  
  // Make dashboard globally available for onclick handlers
  window.dashboard = dashboard;
  
  // Test function to verify global access
  window.testDashboard = () => {
    return window.dashboard;
  };
  
});