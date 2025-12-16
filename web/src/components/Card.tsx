import { motion } from 'framer-motion';
import { useStore, CoachingCard } from '../store/useStore';
import { webNotificationService } from '../lib/notifications';
import {
  Heart,
  DollarSign,
  Clock,
  Leaf,
  CheckCircle,
  X,
  Clock as ClockIcon,
} from 'lucide-react';

interface CardProps {
  card: CoachingCard;
  onAction: (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => void;
}

const domainIcons = {
  health: Heart,
  finance: DollarSign,
  productivity: Clock,
  mindfulness: Leaf,
};

const domainColors = {
  health: 'text-red-400',
  finance: 'text-green-400',
  productivity: 'text-blue-400',
  mindfulness: 'text-purple-400',
};

export default function Card({ card, onAction }: CardProps) {
  const DomainIcon = domainIcons[card.domain];
  const domainColor = domainColors[card.domain];

  const handleDragEnd = (event: any, info: any) => {
    const threshold = 100;
    const { offset } = info;

    if (offset.x > threshold) {
      // Swipe right - complete
      onAction(card.id, 'complete');
      webNotificationService.showCardCompletedToast(card.title);
    } else if (offset.x < -threshold) {
      // Swipe left - dismiss
      onAction(card.id, 'dismiss');
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      drag="x"
      dragConstraints={{ left: 0, right: 0 }}
      dragElastic={0.7}
      onDragEnd={handleDragEnd}
      whileDrag={{ scale: 1.02 }}
      className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border shadow-lg cursor-grab active:cursor-grabbing relative overflow-hidden"
    >
      {/* Swipe indicators */}
      <motion.div
        className="absolute inset-y-0 left-0 flex items-center justify-start pl-4 pointer-events-none"
        initial={{ opacity: 0, x: -20 }}
        whileDrag={{ opacity: 1, x: 0 }}
        drag="x"
        dragConstraints={{ left: -100, right: 100 }}
      >
        <div className="flex items-center space-x-2 text-red-400">
          <X className="w-6 h-6" />
          <span className="font-medium">Dismiss</span>
        </div>
      </motion.div>

      <motion.div
        className="absolute inset-y-0 right-0 flex items-center justify-end pr-4 pointer-events-none"
        initial={{ opacity: 0, x: 20 }}
        whileDrag={{ opacity: 1, x: 0 }}
        drag="x"
        dragConstraints={{ left: -100, right: 100 }}
      >
        <div className="flex items-center space-x-2 text-green-400">
          <CheckCircle className="w-6 h-6" />
          <span className="font-medium">Complete</span>
        </div>
      </motion.div>
      <div className="flex items-start justify-between mb-4">
        <div className={`p-3 rounded-full bg-lifedeck-background ${domainColor}`}>
          <DomainIcon className="w-6 h-6" />
        </div>
        <div className="flex items-center space-x-2">
          <span className="text-xs px-2 py-1 bg-lifedeck-background rounded-full text-lifedeck-textSecondary capitalize">
            {card.actionType}
          </span>
          <span
            className={`text-xs px-2 py-1 rounded-full capitalize ${
              card.priority === 'high'
                ? 'bg-red-500/20 text-red-400'
                : card.priority === 'medium'
                ? 'bg-yellow-500/20 text-yellow-400'
                : 'bg-gray-500/20 text-gray-400'
            }`}
          >
            {card.priority}
          </span>
        </div>
      </div>

      <h3 className="text-xl font-bold text-lifedeck-text mb-2">
        {card.title}
      </h3>

      <p className="text-lifedeck-textSecondary mb-4">
        {card.description}
      </p>

      <div className="bg-lifedeck-background rounded-lg p-4 mb-4">
        <p className="text-lifedeck-text font-medium">
          {card.actionText}
        </p>
      </div>

      {card.tips.length > 0 && (
        <div className="mb-4">
          <h4 className="text-sm font-semibold text-lifedeck-primary mb-2">
            💡 Tips:
          </h4>
          <ul className="space-y-1">
            {card.tips.map((tip, index) => (
              <li key={index} className="text-sm text-lifedeck-textSecondary">
                • {tip}
              </li>
            ))}
          </ul>
        </div>
      )}

      {card.benefits.length > 0 && (
        <div className="mb-6">
          <h4 className="text-sm font-semibold text-lifedeck-primary mb-2">
            🎯 Benefits:
          </h4>
          <ul className="space-y-1">
            {card.benefits.map((benefit, index) => (
              <li key={index} className="text-sm text-lifedeck-textSecondary">
                • {benefit}
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="flex space-x-3">
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => {
            onAction(card.id, 'complete');
            webNotificationService.showCardCompletedToast(card.title);
          }}
          className="flex-1 bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
        >
          <CheckCircle className="w-4 h-4" />
          <span>Complete</span>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => onAction(card.id, 'snooze')}
          className="flex-1 bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
        >
          <ClockIcon className="w-4 h-4" />
          <span>Snooze</span>
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => onAction(card.id, 'dismiss')}
          className="bg-red-500/20 hover:bg-red-500/30 text-red-400 font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center"
        >
          <X className="w-4 h-4" />
        </motion.button>
      </div>

      {/* Drag hint */}
      <div className="mt-4 text-center">
        <span className="text-xs text-lifedeck-textTertiary">
          💡 Drag left to dismiss, right to complete
        </span>
      </div>
    </motion.div>
  );
}