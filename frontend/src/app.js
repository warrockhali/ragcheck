const routes = {
  dashboard: {
    label: 'Dashboard',
    templateId: 'dashboard-template'
  },
  projects: {
    label: 'Projects',
    templateId: 'projects-template'
  },
  endpoints: {
    label: 'RAG Endpoints',
    templateId: 'endpoints-template'
  },
  'test-cases': {
    label: 'Test Cases',
    templateId: 'test-cases-template'
  },
  runs: {
    label: 'Evaluation Runs',
    templateId: 'runs-template'
  },
  results: {
    label: 'Results',
    templateId: 'results-template'
  }
};

function getRouteFromHash() {
  const routeName = window.location.hash.replace('#', '');
  return routes[routeName] ? routeName : 'dashboard';
}

function renderRoute() {
  const routeName = getRouteFromHash();
  const app = document.querySelector('#app');
  const template = document.querySelector(`#${routes[routeName].templateId}`);

  app.replaceChildren(template.content.cloneNode(true));

  document.querySelectorAll('[data-route]').forEach((link) => {
    const isActive = link.dataset.route === routeName;
    link.toggleAttribute('aria-current', isActive);
  });
}

window.addEventListener('hashchange', renderRoute);
window.addEventListener('DOMContentLoaded', renderRoute);
