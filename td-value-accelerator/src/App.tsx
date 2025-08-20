import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { CredentialsProvider } from './contexts/CredentialsContext';
import { GitHubProvider } from './contexts/GitHubContext';
import { SidebarLayout } from './components/shared/SidebarLayout';
import { ConfigurationPage } from './components/configuration/ConfigurationPage';
import { StarterPackSelection } from './components/selection/StarterPackSelection';
import { DeploymentRunner } from './components/deployment/DeploymentRunner';
import { IngestionPage } from './components/ingestion/IngestionPage';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <CredentialsProvider>
        <GitHubProvider>
          <Router>
            <SidebarLayout>
              <Routes>
                <Route path="/" element={<Navigate to="/configuration" replace />} />
                <Route path="/configuration" element={<ConfigurationPage />} />
                <Route path="/selection" element={<StarterPackSelection />} />
                <Route path="/deployment" element={<DeploymentRunner />} />
                <Route path="/ingestion" element={<IngestionPage />} />
              </Routes>
            </SidebarLayout>
          </Router>
        </GitHubProvider>
      </CredentialsProvider>
    </QueryClientProvider>
  );
}

export default App;