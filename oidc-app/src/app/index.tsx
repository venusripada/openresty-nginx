/**
 *
 * App
 *
 * This component is the skeleton around the actual pages, and should only
 * contain code that should be seen on all pages. (e.g. navigation bar)
 */

import * as React from 'react';
import { Helmet } from 'react-helmet-async';
import { Switch, Route, BrowserRouter, useHistory } from 'react-router-dom';

import { GlobalStyle } from '../styles/global-styles';

import { HomePage } from './pages/HomePage/Loadable';
import { NotFoundPage } from './pages/NotFoundPage/Loadable';
import { useTranslation } from 'react-i18next';

// @ts-ignore
import { SecureRoute, Security, LoginCallback } from '@okta/okta-react';
import { OktaAuth, toRelativeUrl } from '@okta/okta-auth-js';

export function App() {
  const history = useHistory();

  const restoreOriginalUri = async (_oktaAuth: any, originalUri: any) => {
    history.push('/');
    // history.replace(toRelativeUrl(originalUri || '/', window.location.origin));
  };

  const oktaAuth = new OktaAuth({
    issuer: 'https://dev-02783336.okta.com/oauth2/default',
    clientId: '0oa4bd4iogwjKTF9K5d7',
    scopes: ['openid', 'profile', 'email', 'offline_access'],
    redirectUri: window.location.origin + '/login/callback',
    tokenManager: {
      autoRenew: true,
      secure: true,
      storage: 'localStorage',
    },
  });

  const { i18n } = useTranslation();
  return (
    // <BrowserRouter>
    <Security oktaAuth={oktaAuth} restoreOriginalUri={restoreOriginalUri}>
      <Helmet
        titleTemplate="%s - React Boilerplate"
        defaultTitle="React Boilerplate"
        htmlAttributes={{ lang: i18n.language }}
      >
        <meta name="description" content="A React Boilerplate application" />
      </Helmet>

      <Switch>
        <Route path="/login/callback" component={LoginCallback} />
        <Route exact path={process.env.PUBLIC_URL + '/'} component={HomePage} />
        <Route component={NotFoundPage} />
      </Switch>
      <GlobalStyle />
    </Security>
    // </BrowserRouter>
  );
}
