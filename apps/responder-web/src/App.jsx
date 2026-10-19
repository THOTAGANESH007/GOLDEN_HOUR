import { BrowserRouter, Routes, Route } from 'react-router-dom';
import EmergencyProfile from './pages/EmergencyProfile';
import NotFound from './pages/NotFound';
import Deactivated from './pages/Deactivated';
import PrivacyPolicy from './pages/PrivacyPolicy';
import TermsOfService from './pages/TermsOfService';
import './styles/emergency.css';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/p/:uid" element={<EmergencyProfile />} />
        <Route path="/p/deactivated" element={<Deactivated />} />
        <Route path="/privacy" element={<PrivacyPolicy />} />
        <Route path="/terms" element={<TermsOfService />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}
