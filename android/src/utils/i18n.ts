import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import * as Localization from 'expo-localization';

const translations = {
    en: {
        welcome: 'Welcome to LifeDeck',
        get_started: 'Get Started',
        daily_deck: 'Daily Deck',
        dashboard: 'Dashboard',
        profile: 'Profile',
        achievements: 'Achievements',
        settings: 'Settings',
    },
    es: {
        welcome: 'Bienvenido a LifeDeck',
        get_started: 'Empezar',
        daily_deck: 'Baraja Diaria',
        dashboard: 'Tablero',
        profile: 'Perfil',
        achievements: 'Logros',
        settings: 'Ajustes',
    },
    fr: {
        welcome: 'Bienvenue sur LifeDeck',
        get_started: 'Commencer',
        daily_deck: 'Jeu Quotidien',
        dashboard: 'Tableau de bord',
        profile: 'Profil',
        achievements: 'Succès',
        settings: 'Paramètres',
    },
    de: {
        welcome: 'Willkommen bei LifeDeck',
        get_started: 'Loslegen',
        daily_deck: 'Tägliches Deck',
        dashboard: 'Dashboard',
        profile: 'Profil',
        achievements: 'Erfolge',
        settings: 'Einstellungen',
    },
    zh: {
        welcome: '欢迎来到 LifeDeck',
        get_started: '开始使用',
        daily_deck: '每日卡组',
        dashboard: '仪表板',
        profile: '个人资料',
        achievements: '成就',
        settings: '设置',
    },
    ar: {
        welcome: 'مرحباً بك في LifeDeck',
        get_started: 'ابدأ الآن',
        daily_deck: 'منصة اليوم',
        dashboard: 'لوحة القيادة',
        profile: 'الملف الشخصي',
        achievements: 'الإنجازات',
        settings: 'الإعدادات',
    },
};

i18n.use(initReactI18next).init({
    resources: {
        en: { translation: translations.en },
        es: { translation: translations.es },
        fr: { translation: translations.fr },
        de: { translation: translations.de },
        zh: { translation: translations.zh },
        ar: { translation: translations.ar },
    },
    lng: Localization.locale.split('-')[0],
    fallbackLng: 'en',
    interpolation: {
        escapeValue: false,
    },
});

export default i18n;
