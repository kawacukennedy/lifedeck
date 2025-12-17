import Link from 'next/link';
import { useRouter } from 'next/router';
import { useStore } from '../store/useStore';
import {
  Home,
  CreditCard,
  BarChart3,
  User,
  Crown,
  Palette,
  HelpCircle,
  Trophy,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: Home },
  { name: 'Deck', href: '/deck', icon: CreditCard },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Achievements', href: '/achievements', icon: Trophy },
  { name: 'Premium', href: '/premium', icon: Crown },
  { name: 'Profile', href: '/profile', icon: User },
  { name: 'Design', href: '/design', icon: Palette },
  { name: 'Help', href: '/help', icon: HelpCircle },
];

export default function Sidebar() {
  const { sidebarOpen } = useStore();
  const router = useRouter();

  return (
    <div
      className={`fixed inset-y-0 left-0 z-50 w-64 bg-lifedeck-surface transform transition-transform duration-300 ease-in-out ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      }`}
    >
      <div className="flex flex-col h-full">
        <div className="flex items-center justify-center h-16 px-4 bg-lifedeck-primary">
          <h1 className="text-xl font-bold text-white">🃏 LifeDeck</h1>
        </div>

        <nav className="flex-1 px-4 py-6 space-y-2">
          {navigation.map((item) => {
            const isActive = router.pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors duration-200 ${
                  isActive
                    ? 'bg-lifedeck-primary text-white'
                    : 'text-lifedeck-textSecondary hover:bg-lifedeck-surface hover:text-lifedeck-text'
                }`}
              >
                <item.icon className="w-5 h-5 mr-3" />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-lifedeck-border">
          <div className="text-xs text-lifedeck-textSecondary">
            © 2024 LifeDeck
          </div>
        </div>
      </div>
    </div>
  );
}