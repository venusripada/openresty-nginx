import * as React from 'react';
import styled from 'styled-components/macro';
import { ReactComponent as DocumentationIcon } from './assets/documentation-icon.svg';
import { ReactComponent as GithubIcon } from './assets/github-icon.svg';

import { useEffect, useState } from 'react';
import { useOktaAuth } from '@okta/okta-react';
import { useHistory } from 'react-router-dom';

function useOktaOidc(): any {
  const [userInfo, setUserInfo] = useState<any>(null);
  const [userInfoLoading, setInfoLoading] = useState<boolean>(true);
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const history = useHistory();

  const { oktaAuth, authState } = useOktaAuth();

  useEffect(() => {
    if (!authState || !authState.isAuthenticated) {
      // When user isn't authenticated, forget any user info
      setUserInfo(null);
    } else {
      setIsAuthenticated(true);
      oktaAuth
        .getUser()
        .then(info => {
          console.debug(info);
          setUserInfo(info);
          setInfoLoading(false);
        })
        .catch(err => {
          console.error(err);
        });
    }
  }, [authState, oktaAuth]);

  const login = async () => oktaAuth.signInWithRedirect();

  const logout = async () => {
    const basename =
      window.location.origin + history.createHref({ pathname: '/' });
    try {
      await oktaAuth.signOut({ postLogoutRedirectUri: basename });
    } catch (err) {
      console.error(err);
    }
  };

  return [userInfo, userInfoLoading, isAuthenticated, login, logout];
}

export function Nav() {
  const [userInfo, userInfoLoading, isAuthenticated, login, logout] =
    useOktaOidc();

  const renderUserActions = () => {
    if (!isAuthenticated) {
      return (
        <div>
          <Button onClick={login}>Login</Button>
        </div>
      );
    }
    if (isAuthenticated && !userInfoLoading) {
      return (
        <React.Fragment>
          <p>Welcome {userInfo.name}</p>
          <div>
            <Button onClick={logout}>Logout</Button>
          </div>
        </React.Fragment>
      );
    }

    return <></>;
  };

  return (
    <Wrapper>
      <Item
        href="https://cansahin.gitbook.io/react-boilerplate-cra-template/"
        target="_blank"
        title="Documentation Page"
        rel="noopener noreferrer"
      >
        <DocumentationIcon />
        Documentation
      </Item>
      <Item
        href="https://github.com/react-boilerplate/react-boilerplate-cra-template"
        target="_blank"
        title="Github Page"
        rel="noopener noreferrer"
      >
        <GithubIcon />
        Github
      </Item>

      {renderUserActions()}
    </Wrapper>
  );
}

const Wrapper = styled.nav`
  display: flex;
  margin-right: -1rem;
`;

const Button = styled.button`
  display: flex;
  margin-right: -1rem;
`;

const Item = styled.a`
  color: ${p => p.theme.primary};
  cursor: pointer;
  text-decoration: none;
  display: flex;
  padding: 0.25rem 1rem;
  font-size: 0.875rem;
  font-weight: 500;
  align-items: center;

  &:hover {
    opacity: 0.8;
  }

  &:active {
    opacity: 0.4;
  }

  .icon {
    margin-right: 0.25rem;
  }
`;
