import { ReactNode } from 'react';
import { useStore } from '../store/useStore';
import Sidebar from './Sidebar';
import Header from './Header';

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const { sidebarOpen, theme } = useStore();

  return (
    <div className={`min-h-screen ${theme === 'dark' ? 'bg-lifedeck-background text-lifedeck-text' : 'bg-white text-gray-900'}`}>
      <Sidebar />
      <div className={`transition-all duration-300 ${sidebarOpen ? 'ml-64' : 'ml-0'}`}>
        <Header />
        <main className="p-6">
          {children}
        </main>
      </div>
    </div>
  );
}