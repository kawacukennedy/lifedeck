import { useStore } from '../store/useStore';
import { Menu, Bell, User } from 'lucide-react';

export default function Header() {
  const { sidebarOpen, setSidebarOpen, user } = useStore();

  return (
    <header className="bg-lifedeck-surface border-b border-lifedeck-border px-6 py-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-2 rounded-lg hover:bg-lifedeck-background transition-colors duration-200"
          >
            <Menu className="w-5 h-5 text-lifedeck-text" />
          </button>

          <div className="ml-4">
            <h2 className="text-lg font-semibold text-lifedeck-text">
              Welcome back, {user?.name || 'User'}!
            </h2>
            <p className="text-sm text-lifedeck-textSecondary">
              Ready for today's coaching cards?
            </p>
          </div>
        </div>

        <div className="flex items-center space-x-4">
          <button className="p-2 rounded-lg hover:bg-lifedeck-background transition-colors duration-200">
            <Bell className="w-5 h-5 text-lifedeck-text" />
          </button>

          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-lifedeck-primary rounded-full flex items-center justify-center">
              <User className="w-4 h-4 text-white" />
            </div>
            <span className="text-sm font-medium text-lifedeck-text">
              {user?.name || 'Guest'}
            </span>
          </div>
        </div>
      </div>
    </header>
  );
}