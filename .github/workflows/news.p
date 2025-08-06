import React, { useEffect, useState, createContext, useContext } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged, GoogleAuthProvider, signInWithPopup, signOut } from 'firebase/auth';
import { getFirestore, collection, addDoc, onSnapshot, query, orderBy, serverTimestamp, doc, deleteDoc, limit, where } from 'firebase/firestore'; // 'where' added here
import { getStorage, ref, uploadBytesResumable, getDownloadURL } from 'firebase/storage';

// Create a context for Firebase and User data
const AppContext = createContext(null);

// Custom hook to use the AppContext
const useAppContext = () => useContext(AppContext);

// Main App component
export default function App() {
  const [db, setDb] = useState(null);
  const [auth, setAuth] = useState(null);
  const [storage, setStorage] = useState(null);
  const [userId, setUserId] = useState(null);
  const [userEmail, setUserEmail] = useState(null);
  const [isAuthReady, setIsAuthReady] = useState(false);
  const [currentPage, setCurrentPage] = useState('home'); // 'home', 'addNews', 'addAd'

  useEffect(() => {
    // Initialize Firebase
    const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';
    const firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : {};

    if (Object.keys(firebaseConfig).length > 0) {
      const app = initializeApp(firebaseConfig);
      const firestoreDb = getFirestore(app);
      const firebaseAuth = getAuth(app);
      const firebaseStorage = getStorage(app);
      setDb(firestoreDb);
      setAuth(firebaseAuth);
      setStorage(firebaseStorage);

      // Listen for auth state changes
      const unsubscribe = onAuthStateChanged(firebaseAuth, (user) => {
        if (user) {
          setUserId(user.uid);
          setUserEmail(user.email);
        } else {
          setUserId(null);
          setUserEmail(null);
        }
        setIsAuthReady(true); // Auth state is ready
      });

      // Initial anonymous sign-in if no custom token (for public access)
      const signInInitial = async () => {
        try {
          if (typeof __initial_auth_token !== 'undefined') {
            await signInWithCustomToken(firebaseAuth, __initial_auth_token);
          } else {
            await signInAnonymously(firebaseAuth);
          }
        } catch (error) {
          console.error("Firebase initial authentication error:", error);
        }
      };
      signInInitial();

      return () => unsubscribe(); // Cleanup auth listener
    } else {
      console.warn("Firebase config not found. App will run without persistence.");
      setIsAuthReady(true); // Still set to true if no config, for UI to render
    }
  }, []);

  const contextValue = { db, auth, storage, userId, userEmail, isAuthReady, setCurrentPage };

  if (!isAuthReady) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100">
        <div className="text-xl font-semibold text-gray-700">हाम्रो संसार लोड हुँदैछ...</div>
      </div>
    );
  }

  return (
    <AppContext.Provider value={contextValue}>
      <div className="min-h-screen bg-gray-50 font-inter">
        <Header />
        <main className="container mx-auto p-4 md:p-6 lg:p-8">
          {userId && (
            <div className="mb-6 p-3 bg-blue-100 text-blue-800 rounded-lg shadow-sm">
              <p className="text-sm">तपाईंको प्रयोगकर्ता ID: <span className="font-mono break-all">{userId}</span></p>
              {userEmail && <p className="text-sm">तपाईंको इमेल: <span className="font-mono break-all">{userEmail}</span></p>}
              <p className="text-xs mt-1">यो ID अन्य प्रयोगकर्ताहरूसँग समाचार वा विज्ञापन साझेदारी गर्न प्रयोग गर्न सकिन्छ।</p>
            </div>
          )}

          {currentPage === 'home' && <HomePage />}
          {currentPage === 'addNews' && <AddNewsForm />}
          {currentPage === 'addAd' && <AddAdForm />}
        </main>
      </div>
    </AppContext.Provider>
  );
}

// Header Component
const Header = () => {
  const { auth, userId, userEmail, setCurrentPage } = useAppContext();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleGoogleSignIn = async () => {
    const provider = new GoogleAuthProvider();
    try {
      await signInWithPopup(auth, provider);
      console.log("Google Sign-in successful!");
    } catch (error) {
      console.error("Google Sign-in error:", error);
    }
  };

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      console.log("Signed out successfully!");
      setCurrentPage('home'); // Redirect to home after logout
    } catch (error) {
      console.error("Sign-out error:", error);
    }
  };

  return (
    <header className="bg-gradient-to-r from-blue-600 to-purple-700 text-white shadow-lg p-4">
      <div className="container mx-auto flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-wide cursor-pointer" onClick={() => setCurrentPage('home')}>
          हाम्रो संसार
        </h1>
        <nav className="hidden md:flex items-center space-x-6">
          <button onClick={() => setCurrentPage('home')} className="nav-button">गृहपृष्ठ</button>
          {userEmail ? ( // Show add buttons only if logged in with Google
            <>
              <button onClick={() => setCurrentPage('addNews')} className="nav-button">समाचार थप्नुहोस्</button>
              <button onClick={() => setCurrentPage('addAd')} className="nav-button">विज्ञापन थप्नुहोस्</button>
              <button onClick={handleSignOut} className="nav-button bg-red-500 hover:bg-red-600">बाहिर निस्कनुहोस् ({userEmail})</button>
            </>
          ) : (
            <button onClick={handleGoogleSignIn} className="nav-button bg-green-500 hover:bg-green-600">Google मार्फत लगइन गर्नुहोस्</button>
          )}
        </nav>
        <div className="md:hidden">
          <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} className="text-white focus:outline-none">
            <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              {isMobileMenuOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path>
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16"></path>
              )}
            </svg>
          </button>
        </div>
      </div>
      {isMobileMenuOpen && (
        <nav className="md:hidden bg-blue-700 mt-4 rounded-lg shadow-md">
          <ul className="flex flex-col p-4 space-y-2">
            <li><button onClick={() => { setCurrentPage('home'); setIsMobileMenuOpen(false); }} className="nav-button-mobile">गृहपृष्ठ</button></li>
            {userEmail ? (
              <>
                <li><button onClick={() => { setCurrentPage('addNews'); setIsMobileMenuOpen(false); }} className="nav-button-mobile">समाचार थप्नुहोस्</button></li>
                <li><button onClick={() => { setCurrentPage('addAd'); setIsMobileMenuOpen(false); }} className="nav-button-mobile">विज्ञापन थप्नुहोस्</button></li>
                <li><button onClick={() => { handleSignOut(); setIsMobileMenuOpen(false); }} className="nav-button-mobile bg-red-500 hover:bg-red-600">बाहिर निस्कनुहोस् ({userEmail})</button></li>
              </>
            ) : (
              <li><button onClick={() => { handleGoogleSignIn(); setIsMobileMenuOpen(false); }} className="nav-button-mobile bg-green-500 hover:bg-green-600">Google मार्फत लगइन गर्नुहोस्</button></li>
            )}
          </ul>
        </nav>
      )}
      {/* Removed the style jsx block as it's not standard React in this Canvas environment */}
    </header>
  );
};

// Home Page Component (displays news and ads)
const HomePage = () => {
  const { db, userId, isAuthReady } = useAppContext();
  const [news, setNews] = useState([]);
  const [ads, setAds] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState('सबै');
  const [recentNewsByCategory, setRecentNewsByCategory] = useState({});

  const categories = ['सबै', 'राजनीति', 'खेलकुद', 'प्रविधि', 'मनोरञ्जन', 'अर्थतन्त्र', 'स्वास्थ्य', 'अन्य'];
  const ribbonCategories = ['राजनीति', 'खेलकुद', 'प्रविधि']; // Categories for the recent news ribbon

  useEffect(() => {
    if (!db || !isAuthReady) return;

    // Fetch news
    const newsCollectionRef = collection(db, `artifacts/${__app_id}/public/data/news`);
    const newsQuery = query(newsCollectionRef, orderBy('timestamp', 'desc'));

    const unsubscribeNews = onSnapshot(newsQuery, (snapshot) => {
      const newsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setNews(newsData);
    }, (error) => {
      console.error("Error fetching news:", error);
    });

    // Fetch advertisements
    const adsCollectionRef = collection(db, `artifacts/${__app_id}/public/data/advertisements`);
    const adsQuery = query(adsCollectionRef, orderBy('timestamp', 'desc'));

    const unsubscribeAds = onSnapshot(adsQuery, (snapshot) => {
      const adsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setAds(adsData);
    }, (error) => {
      console.error("Error fetching advertisements:", error);
    });

    // Fetch recent news for ribbon by category
    const fetchRecentNewsForRibbon = () => {
      const tempRecentNews = {};
      ribbonCategories.forEach(cat => {
        const categoryQuery = query(
          collection(db, `artifacts/${__app_id}/public/data/news`),
          where('category', '==', cat),
          orderBy('timestamp', 'desc'),
          limit(3) // Get top 3 recent news for each category
        );
        onSnapshot(categoryQuery, (snapshot) => {
          tempRecentNews[cat] = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
          setRecentNewsByCategory({ ...tempRecentNews });
        }, (error) => {
          console.error(`Error fetching recent news for ${cat}:`, error);
        });
      });
    };

    fetchRecentNewsForRibbon(); // Initial fetch

    return () => {
      unsubscribeNews();
      unsubscribeAds();
      // No explicit unsubscribe for ribbon as it's within the effect's scope and will re-run
    };
  }, [db, isAuthReady, userId]); // userId added to dependencies to potentially re-fetch if auth state changes significantly

  const filteredNews = selectedCategory === 'सबै'
    ? news
    : news.filter(article => article.category === selectedCategory);

  const handleDeleteNews = async (id) => {
    if (!db || !userId) return;
    try {
      await deleteDoc(doc(db, `artifacts/${__app_id}/public/data/news`, id));
      console.log("News deleted successfully!");
    } catch (error) {
      console.error("Error deleting news:", error);
    }
  };

  const handleDeleteAd = async (id) => {
    if (!db || !userId) return;
    try {
      await deleteDoc(doc(db, `artifacts/${__app_id}/public/data/advertisements`, id));
      console.log("Advertisement deleted successfully!");
    } catch (error) {
      console.error("Error deleting advertisement:", error);
    }
  };

  return (
    <div>
      <div className="mb-8 p-4 bg-white rounded-lg shadow-md">
        <h2 className="text-2xl font-semibold text-gray-800 mb-4">समाचार वर्गहरू</h2>
        <div className="flex flex-wrap gap-2">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                selectedCategory === category
                  ? 'bg-blue-600 text-white shadow-md'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Recent News Ribbon */}
      <div className="mb-8 p-4 bg-gradient-to-r from-yellow-100 to-orange-100 rounded-lg shadow-md">
        <h2 className="text-2xl font-semibold text-gray-800 mb-4">भर्खरका समाचार (विषय अनुसार)</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {ribbonCategories.map(cat => (
            <div key={cat} className="bg-white p-4 rounded-lg shadow-sm border border-yellow-200">
              <h3 className="text-lg font-bold text-gray-800 mb-3 border-b pb-2 border-yellow-300">{cat}</h3>
              {recentNewsByCategory[cat] && recentNewsByCategory[cat].length > 0 ? (
                <ul className="space-y-2">
                  {recentNewsByCategory[cat].map(newsItem => (
                    <li key={newsItem.id} className="text-gray-700 text-sm hover:text-blue-600 cursor-pointer">
                      • {newsItem.title}
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-gray-500 text-sm">यस वर्गमा कुनै भर्खरको समाचार छैन।</p>
              )}
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2">
          <h2 className="text-3xl font-bold text-gray-800 mb-6">ताजा समाचार</h2>
          {filteredNews.length === 0 ? (
            <p className="text-gray-600 text-lg">कुनै समाचार उपलब्ध छैन।</p>
          ) : (
            <div className="grid grid-cols-1 gap-6">
              {filteredNews.map(article => (
                <NewsCard key={article.id} article={article} onDelete={handleDeleteNews} currentUserId={userId} />
              ))}
            </div>
          )}
        </div>
        <div className="md:col-span-1">
          <h2 className="text-3xl font-bold text-gray-800 mb-6">विज्ञापन</h2>
          {ads.length === 0 ? (
            <p className="text-gray-600 text-lg">कुनै विज्ञापन उपलब्ध छैन।</p>
          ) : (
            <div className="grid grid-cols-1 gap-6">
              {ads.map(ad => (
                <Advertisement key={ad.id} ad={ad} onDelete={handleDeleteAd} currentUserId={userId} />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// News Card Component
const NewsCard = ({ article, onDelete, currentUserId }) => {
  const isOwner = article.userId === currentUserId;

  return (
    <div className="bg-white rounded-lg shadow-lg overflow-hidden border border-gray-200 hover:shadow-xl transition-shadow duration-300 ease-in-out">
      {article.imageUrl && (
        <div className="w-full h-60 bg-gray-200 flex items-center justify-center overflow-hidden">
          <img
            src={article.imageUrl}
            alt={article.title}
            className="w-full h-full object-cover"
            onError={(e) => { e.target.onerror = null; e.target.src = `https://placehold.co/600x400/cccccc/333333?text=${encodeURIComponent(article.title || 'समाचार छवि')}`; }}
          />
        </div>
      )}
      <div className="p-6">
        <span className="inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-3 py-1 rounded-full mb-3">
          {article.category}
        </span>
        <h3 className="text-2xl font-bold text-gray-900 mb-3 leading-tight">{article.title}</h3>
        <p className="text-gray-700 leading-relaxed mb-4">{article.content}</p>
        <div className="flex flex-wrap justify-between items-center text-sm text-gray-500 mt-4 border-t pt-4">
          <div className="flex flex-col">
            {article.journalistName && (
              <span className="text-gray-600 font-medium mb-1">पत्रकार: {article.journalistName}</span>
            )}
            <span>
              प्रकाशित: {article.timestamp ? new Date(article.timestamp.toDate()).toLocaleString('ne-NP') : 'उपलब्ध छैन'}
            </span>
          </div>
          {isOwner && (
            <button
              onClick={() => onDelete(article.id)}
              className="ml-4 px-3 py-1 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors duration-200 text-sm mt-2 md:mt-0"
            >
              मेट्नुहोस्
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

// Advertisement Component
const Advertisement = ({ ad, onDelete, currentUserId }) => {
  const isOwner = ad.userId === currentUserId;

  return (
    <div className="bg-white rounded-lg shadow-lg overflow-hidden border border-gray-200 hover:shadow-xl transition-shadow duration-300 ease-in-out">
      <a href={ad.linkUrl} target="_blank" rel="noopener noreferrer" className="block">
        <div className="w-full h-48 bg-gray-200 flex items-center justify-center overflow-hidden">
          {ad.imageUrl ? (
            <img
              src={ad.imageUrl}
              alt={ad.title}
              className="w-full h-full object-cover"
              onError={(e) => { e.target.onerror = null; e.target.src = `https://placehold.co/400x200/cccccc/333333?text=${encodeURIComponent(ad.title || 'विज्ञापन')}`; }}
            />
          ) : (
            <span className="text-gray-500 text-lg">विज्ञापन छवि उपलब्ध छैन</span>
          )}
        </div>
        <div className="p-4">
          <h3 className="text-xl font-semibold text-gray-900 mb-2">{ad.title}</h3>
          <p className="text-sm text-blue-600 hover:underline">थप जान्नुहोस्</p>
        </div>
      </a>
      {isOwner && (
        <div className="p-4 border-t border-gray-200 flex justify-end">
          <button
            onClick={() => onDelete(ad.id)}
            className="px-3 py-1 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors duration-200 text-sm"
          >
            मेट्नुहोस्
          </button>
        </div>
      )}
    </div>
  );
};

// Add News Form Component
const AddNewsForm = () => {
  const { db, storage, userId, userEmail, setCurrentPage } = useAppContext();
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [category, setCategory] = useState('राजनीति');
  const [journalistName, setJournalistName] = useState('');
  const [imageFile, setImageFile] = useState(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' or 'error'

  const categories = ['राजनीति', 'खेलकुद', 'प्रविधि', 'मनोरञ्जन', 'अर्थतन्त्र', 'स्वास्थ्य', 'अन्य'];

  // Redirect if not logged in with Google
  useEffect(() => {
    if (!userEmail) {
      setMessage('समाचार थप्नको लागि कृपया Google मार्फत लगइन गर्नुहोस्।');
      setMessageType('error');
      setTimeout(() => {
        setCurrentPage('home');
      }, 3000);
    }
  }, [userEmail, setCurrentPage]);

  const handleFileChange = (e) => {
    if (e.target.files[0]) {
      setImageFile(e.target.files[0]);
    } else {
      setImageFile(null);
    }
  };

  const uploadImage = async () => {
    if (!imageFile) return null;

    setIsUploading(true);
    const storageRef = ref(storage, `artifacts/${__app_id}/public/images/news/${imageFile.name}_${Date.now()}`);
    const uploadTask = uploadBytesResumable(storageRef, imageFile);

    return new Promise((resolve, reject) => {
      uploadTask.on('state_changed',
        (snapshot) => {
          const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          setUploadProgress(progress);
        },
        (error) => {
          console.error("Image upload error:", error);
          setMessage(`छवि अपलोड गर्न असफल भयो: ${error.message}`);
          setMessageType('error');
          setIsUploading(false);
          reject(error);
        },
        async () => {
          const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
          setIsUploading(false);
          resolve(downloadURL);
        }
      );
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!db || !userId || !userEmail) {
      setMessage('डेटाबेस उपलब्ध छैन वा प्रयोगकर्ता प्रमाणीकरण गरिएको छैन।');
      setMessageType('error');
      return;
    }

    if (!title || !content || !category || !journalistName) {
      setMessage('कृपया सबै आवश्यक क्षेत्रहरू भर्नुहोस्।');
      setMessageType('error');
      return;
    }

    let imageUrl = null;
    if (imageFile) {
      try {
        imageUrl = await uploadImage();
      } catch (error) {
        return; // Stop submission if image upload fails
      }
    }

    try {
      await addDoc(collection(db, `artifacts/${__app_id}/public/data/news`), {
        title,
        content,
        category,
        journalistName,
        imageUrl, // Add image URL to Firestore document
        userId,
        timestamp: serverTimestamp(),
      });
      setMessage('समाचार सफलतापूर्वक थपियो!');
      setMessageType('success');
      setTitle('');
      setContent('');
      setCategory('राजनीति');
      setJournalistName('');
      setImageFile(null);
      setUploadProgress(0);
      setTimeout(() => {
        setMessage('');
        setCurrentPage('home'); // Go back to home after successful submission
      }, 2000);
    } catch (error) {
      console.error("Error adding document: ", error);
      setMessage(`समाचार थप्न असफल भयो: ${error.message}`);
      setMessageType('error');
    }
  };

  if (!userEmail) {
    return (
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-2xl mx-auto text-center">
        <h2 className="text-2xl font-bold text-gray-800 mb-4">लगइन आवश्यक छ</h2>
        <p className="text-gray-700 mb-6">समाचार थप्नको लागि कृपया Google मार्फत लगइन गर्नुहोस्।</p>
        {message && (
          <div className={`p-3 mb-4 rounded-md ${messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            {message}
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="bg-white p-8 rounded-lg shadow-lg max-w-2xl mx-auto">
      <h2 className="text-3xl font-bold text-gray-800 mb-6 text-center">नयाँ समाचार थप्नुहोस्</h2>
      {message && (
        <div className={`p-3 mb-4 rounded-md text-center ${messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
          {message}
        </div>
      )}
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="title" className="block text-gray-700 text-sm font-bold mb-2">शीर्षक:</label>
          <input
            type="text"
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="समाचारको शीर्षक लेख्नुहोस्"
            required
          />
        </div>
        <div className="mb-4">
          <label htmlFor="content" className="block text-gray-700 text-sm font-bold mb-2">सामग्री:</label>
          <textarea
            id="content"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows="6"
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="समाचारको विस्तृत सामग्री लेख्नुहोस्"
            required
          ></textarea>
        </div>
        <div className="mb-4">
          <label htmlFor="journalistName" className="block text-gray-700 text-sm font-bold mb-2">पत्रकारको नाम:</label>
          <input
            type="text"
            id="journalistName"
            value={journalistName}
            onChange={(e) => setJournalistName(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="पत्रकारको नाम"
            required
          />
        </div>
        <div className="mb-4">
          <label htmlFor="category" className="block text-gray-700 text-sm font-bold mb-2">वर्ग:</label>
          <select
            id="category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="shadow border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          >
            {categories.map(cat => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>
        <div className="mb-6">
          <label htmlFor="imageUpload" className="block text-gray-700 text-sm font-bold mb-2">छवि अपलोड गर्नुहोस्:</label>
          <input
            type="file"
            id="imageUpload"
            accept="image/*"
            onChange={handleFileChange}
            className="block w-full text-sm text-gray-700 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
          />
          {isUploading && (
            <div className="w-full bg-gray-200 rounded-full h-2.5 mt-2">
              <div className="bg-blue-600 h-2.5 rounded-full" style={{ width: `${uploadProgress}%` }}></div>
              <span className="text-xs text-gray-600 mt-1 block">{Math.round(uploadProgress)}% अपलोड भयो</span>
            </div>
          )}
        </div>
        <div className="flex items-center justify-between">
          <button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg focus:outline-none focus:shadow-outline transition duration-300 ease-in-out transform hover:scale-105"
            disabled={isUploading}
          >
            {isUploading ? 'अपलोड गर्दै...' : 'समाचार प्रकाशित गर्नुहोस्'}
          </button>
          <button
            type="button"
            onClick={() => setCurrentPage('home')}
            className="bg-gray-500 hover:bg-gray-600 text-white font-bold py-3 px-6 rounded-lg focus:outline-none focus:shadow-outline transition duration-300 ease-in-out transform hover:scale-105"
          >
            रद्द गर्नुहोस्
          </button>
        </div>
      </form>
    </div>
  );
};

// Add Advertisement Form Component
const AddAdForm = () => {
  const { db, userId, userEmail, setCurrentPage } = useAppContext();
  const [title, setTitle] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [linkUrl, setLinkUrl] = useState('');
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' or 'error'

  // Redirect if not logged in with Google
  useEffect(() => {
    if (!userEmail) {
      setMessage('विज्ञापन थप्नको लागि कृपया Google मार्फत लगइन गर्नुहोस्।');
      setMessageType('error');
      setTimeout(() => {
        setCurrentPage('home');
      }, 3000);
    }
  }, [userEmail, setCurrentPage]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!db || !userId || !userEmail) {
      setMessage('डेटाबेस उपलब्ध छैन वा प्रयोगकर्ता प्रमाणीकरण गरिएको छैन।');
      setMessageType('error');
      return;
    }

    if (!title || !imageUrl || !linkUrl) {
      setMessage('कृपया सबै क्षेत्रहरू भर्नुहोस्।');
      setMessageType('error');
      return;
    }

    try {
      await addDoc(collection(db, `artifacts/${__app_id}/public/data/advertisements`), {
        title,
        imageUrl,
        linkUrl,
        userId,
        timestamp: serverTimestamp(),
      });
      setMessage('विज्ञापन सफलतापूर्वक थपियो!');
      setMessageType('success');
      setTitle('');
      setImageUrl('');
      setLinkUrl('');
      setTimeout(() => {
        setMessage('');
        setCurrentPage('home'); // Go back to home after successful submission
      }, 2000);
    } catch (error) {
      console.error("Error adding document: ", error);
      setMessage(`विज्ञापन थप्न असफल भयो: ${error.message}`);
      setMessageType('error');
    }
  };

  if (!userEmail) {
    return (
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-2xl mx-auto text-center">
        <h2 className="text-2xl font-bold text-gray-800 mb-4">लगइन आवश्यक छ</h2>
        <p className="text-gray-700 mb-6">विज्ञापन थप्नको लागि कृपया Google मार्फत लगइन गर्नुहोस्।</p>
        {message && (
          <div className={`p-3 mb-4 rounded-md ${messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            {message}
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="bg-white p-8 rounded-lg shadow-lg max-w-2xl mx-auto">
      <h2 className="text-3xl font-bold text-gray-800 mb-6 text-center">नयाँ विज्ञापन थप्नुहोस्</h2>
      {message && (
        <div className={`p-3 mb-4 rounded-md text-center ${messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
          {message}
        </div>
      )}
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="adTitle" className="block text-gray-700 text-sm font-bold mb-2">विज्ञापन शीर्षक:</label>
          <input
            type="text"
            id="adTitle"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="विज्ञापनको शीर्षक लेख्नुहोस्"
            required
          />
        </div>
        <div className="mb-4">
          <label htmlFor="imageUrl" className="block text-gray-700 text-sm font-bold mb-2">छवि URL:</label>
          <input
            type="url"
            id="imageUrl"
            value={imageUrl}
            onChange={(e) => setImageUrl(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="विज्ञापन छविको URL"
            required
          />
        </div>
        <div className="mb-6">
          <label htmlFor="linkUrl" className="block text-gray-700 text-sm font-bold mb-2">लिङ्क URL:</label>
          <input
            type="url"
            id="linkUrl"
            value={linkUrl}
            onChange={(e) => setLinkUrl(e.target.value)}
            className="shadow appearance-none border rounded-lg w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="विज्ञापनको लिङ्क URL"
            required
          />
        </div>
        <div className="flex items-center justify-between">
          <button
            type="submit"
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg focus:outline-none focus:shadow-outline transition duration-300 ease-in-out transform hover:scale-105"
          >
            विज्ञापन प्रकाशित गर्नुहोस्
          </button>
          <button
            type="button"
            onClick={() => setCurrentPage('home')}
            className="bg-gray-500 hover:bg-gray-600 text-white font-bold py-3 px-6 rounded-lg focus:outline-none focus:shadow-outline transition duration-300 ease-in-out transform hover:scale-105"
          >
            रद्द गर्नुहोस्
          </button>
        </div>
      </form>
    </div>
  );
};
