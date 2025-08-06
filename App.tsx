
import React, { useState } from 'react';

// Define types for better code quality and maintainability
type NavLink = {
  id: string;
  title: string;
};

// Main Application Component
export default function App() {
  const [activeTab, setActiveTab] = useState('home');

  const navLinks: NavLink[] = [
    { id: 'home', title: 'Home' },
    { id: 'about', title: 'About' },
    { id: 'portfolio', title: 'Portfolio' },
    { id: 'contact', title: 'Contact' },
  ];

  return (
    <div className="bg-gray-50 min-h-screen">
      <Header navLinks={navLinks} activeTab={activeTab} setActiveTab={setActiveTab} />
      <main className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'home' && <HomeSection />}
        {activeTab === 'about' && <AboutSection />}
        {activeTab === 'portfolio' && <PortfolioSection />}
        {activeTab === 'contact' && <ContactSection />}
      </main>
      <Footer />
    </div>
  );
}

// Header Component
type HeaderProps = {
  navLinks: NavLink[];
  activeTab: string;
  setActiveTab: (id: string) => void;
};

const Header: React.FC<HeaderProps> = ({ navLinks, activeTab, setActiveTab }) => (
  <header className="bg-white/80 backdrop-blur-sm shadow-sm sticky top-0 z-50">
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 flex justify-between items-center py-3">
      <div className="flex items-center space-x-2">
        <div className="w-10 h-10 bg-[#ff4081] rounded-full flex items-center justify-center text-white font-bold text-xl leading-none">L</div>
        <span className="font-bold text-2xl text-slate-800">Lokendra</span>
      </div>
      <nav className="hidden md:flex items-center space-x-8">
        {navLinks.map((link) => (
          <button
            key={link.id}
            onClick={() => setActiveTab(link.id)}
            className={`font-semibold pb-1 ${
              activeTab === link.id
                ? 'text-[#ff4081] border-b-2 border-[#ff4081]'
                : 'text-slate-600 hover:text-[#ff4081]'
            }`}
          >
            {link.title}
          </button>
        ))}
      </nav>
    </div>
  </header>
);

// Home Section Component
const HomeSection = () => (
  <section className="py-16">
    <div className="grid md:grid-cols-2 gap-12 items-center">
      <div className="text-center md:text-left">
        <div className="flex items-center justify-center md:justify-start gap-3 mb-4">
          <div className="w-10 h-0.5 bg-[#ff4081]"></div>
          <span className="text-sm font-bold uppercase tracking-widest text-[#ff4081]">A Creative Developer</span>
        </div>
        <h1 className="text-4xl md:text-5xl lg:text-6xl font-extrabold text-slate-800 leading-tight">
          HI, I'M <span className="text-[#ff4081]">LOKENDRA</span><br/> GAIRE
        </h1>
        <p className="mt-6 text-slate-500 text-lg max-w-lg mx-auto md:mx-0">
          I build modern, creative, and fast digital experiences for everyone. Diligent and resourceful with a passion for technology and continuous learning.
        </p>
         <div className="mt-8 flex items-center justify-center md:justify-start space-x-3">
            <a href="mailto:lokendra.gaire.70@gmail.com" title="Email" className="w-12 h-12 rounded-full bg-white shadow-md border border-gray-200 flex items-center justify-center text-slate-600 hover:bg-[#ff4081]/10 hover:text-[#ff4081] transition-all"><svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg></a>
            <a href="#" title="YouTube" className="w-12 h-12 rounded-full bg-white shadow-md border border-gray-200 flex items-center justify-center text-slate-600 hover:bg-[#ff4081]/10 hover:text-[#ff4081] transition-all"><svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor"><path d="M21.582,6.186c-0.23-0.86-0.908-1.538-1.768-1.768C18.254,4,12,4,12,4S5.746,4,4.186,4.418 c-0.86,0.23-1.538,0.908-1.768,1.768C2,7.746,2,12,2,12s0,4.254,0.418,5.814c0.23,0.86,0.908,1.538,1.768,1.768 C5.746,20,12,20,12,20s6.254,0,7.814-0.418c0.861-0.23,1.538-0.908,1.768-1.768C22,16.254,22,12,22,12S22,7.746,21.582,6.186z M10,15.464V8.536L16,12L10,15.464z"></path></svg></a>
            <a href="tel:+977-9869065252" title="Phone" className="w-12 h-12 rounded-full bg-white shadow-md border border-gray-200 flex items-center justify-center text-slate-600 hover:bg-[#ff4081]/10 hover:text-[#ff4081] transition-all"><svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg></a>
        </div>
      </div>
      <div className="mt-8 md:mt-0">
        <img src="/brp.jpg" onError={(e: React.SyntheticEvent<HTMLImageElement, Event>) => { e.currentTarget.src = 'https://storage.googleapis.com/pr-prd-shiny-app-files/e5b6b473-a212-4770-9751-6d4a23f12461/brp.jpg'; }} alt="Lokendra Gaire" className="w-full h-auto rounded-lg shadow-2xl"/>
      </div>
    </div>
  </section>
);

// About Section Component
const AboutSection = () => (
    <section className="py-16">
        <h2 className="text-4xl font-bold text-center text-slate-800 mb-12">About Me</h2>
        <div className="bg-white p-8 rounded-lg shadow-lg max-w-4xl mx-auto">
             <div className="grid md:grid-cols-2 gap-8">
                <div className="flex items-start gap-4">
                    <svg className="w-8 h-8 text-[#ff4081] flex-shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm6-11a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
                    <div>
                        <h4 className="text-xl font-bold text-slate-800">Family Details</h4>
                        <ul className="mt-2 text-slate-600 space-y-1">
                            <li><strong>Grand Father:</strong> Purna prasad Gaire</li>
                            <li><strong>Grand Mother:</strong> Durga Devi Gaire</li>
                            <li><strong>Father:</strong> Punakhar Gaire</li>
                            <li><strong>Mother:</strong> Ishwori Gaire</li>
                            <li><strong>Brother:</strong> Tomendra Gaire</li>
                        </ul>
                    </div>
                </div>
                <div className="space-y-8">
                    <div className="flex items-start gap-4">
                        <svg className="w-8 h-8 text-[#ff4081] flex-shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M12 14l9-5-9-5-9 5 9 5z" /><path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-5.998 12.078 12.078 0 01.665-6.479L12 14z" /><path d="M9 17v-6.5l3-1.667 3 1.667V17" /></svg>
                        <div>
                            <h4 className="text-xl font-bold text-slate-800">Qualification</h4>
                            <p className="mt-2 text-slate-600">Bachelor Degree In Business Study</p>
                        </div>
                    </div>
                    <div className="flex items-start gap-4">
                        <svg className="w-8 h-8 text-[#ff4081] flex-shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                        <div>
                            <h4 className="text-xl font-bold text-slate-800">Birth Place</h4>
                            <p className="mt-2 text-slate-600">Galkot Municipality-2, Thana, Baglung</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
);

// Portfolio Section Component
const PortfolioSection = () => (
    <section className="py-16">
        <h2 className="text-4xl font-bold text-center text-slate-800 mb-12">My Portfolio</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl hover:-translate-y-1 transition-all">
                <h4 className="text-xl font-bold text-slate-800">MIS Operator</h4>
                <p className="text-sm text-slate-500 mt-1 mb-4">Galkot Municipality Office (2079-11-11 BS - Present)</p>
                <p className="text-slate-600">Responsible for data management, personal event registration, and handling Social Security Allowances.</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl hover:-translate-y-1 transition-all">
                <h4 className="text-xl font-bold text-slate-800">Financial Literacy Facilitator</h4>
                <p className="text-sm text-slate-500 mt-1 mb-4">Sami Project</p>
                <p className="text-slate-600">Conducted training and counseling on financial management for project participants.</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl hover:-translate-y-1 transition-all">
                <h4 className="text-xl font-bold text-slate-800">Teacher</h4>
                <p className="text-sm text-slate-500 mt-1 mb-4">Secondary School</p>
                <p className="text-slate-600">Taught computer science and mathematics, developed lesson plans, and mentored students for competitions.</p>
            </div>
        </div>
    </section>
);

// Contact Section Component
const ContactSection = () => (
    <section className="py-16">
        <h2 className="text-4xl font-bold text-center text-slate-800 mb-12">Get In Touch</h2>
        <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
            <div className="space-y-6">
                 <div className="bg-white p-6 rounded-lg shadow-lg flex items-center gap-4">
                    <svg className="w-8 h-8 text-[#ff4081] flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>
                    <div>
                        <h3 className="text-xl font-bold text-slate-800">Email</h3>
                        <a href="mailto:lokendra.gaire.70@gmail.com" className="text-slate-600 hover:text-[#ff4081]">lokendra.gaire.70@gmail.com</a>
                    </div>
                 </div>
                 <div className="bg-white p-6 rounded-lg shadow-lg flex items-center gap-4">
                    <svg className="w-8 h-8 text-[#ff4081] flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" /></svg>
                    <div>
                        <h3 className="text-xl font-bold text-slate-800">Mobile No</h3>
                        <a href="tel:+977-9869065252" className="text-slate-600 hover:text-[#ff4081]">+977-9869065252</a>
                    </div>
                </div>
            </div>
             <div className="bg-white p-8 rounded-lg shadow-lg">
                <h3 className="text-2xl font-bold text-slate-800 mb-4">Send a Message</h3>
                <form>
                    <div className="mb-4">
                        <label htmlFor="name" className="block text-slate-600 mb-1">Your Name</label>
                        <input type="text" id="name" className="w-full p-3 bg-gray-100 rounded-md border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[#ff4081]" />
                    </div>
                    <div className="mb-4">
                        <label htmlFor="email" className="block text-slate-600 mb-1">Your Email</label>
                        <input type="email" id="email" className="w-full p-3 bg-gray-100 rounded-md border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[#ff4081]" />
                    </div>
                    <div className="mb-4">
                         <label htmlFor="message" className="block text-slate-600 mb-1">Your Message</label>
                        <textarea id="message" rows={4} className="w-full p-3 bg-gray-100 rounded-md border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[#ff4081]"></textarea>
                    </div>
                    <button type="submit" className="w-full bg-[#ff4081] text-white font-bold py-3 px-4 rounded-md hover:bg-[#f50057] transition-all">Send Message</button>
                </form>
            </div>
        </div>
    </section>
);

// Footer Component
const Footer = () => (
    <footer className="bg-white border-t border-gray-200 mt-12 py-6">
        <div className="container mx-auto text-center text-slate-500">
            <p>© 2024 Lokendra Gaire. All Rights Reserved.</p>
        </div>
    </footer>
);
