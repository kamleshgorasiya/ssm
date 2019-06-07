import { TestBed,async,inject } from '@angular/core/testing';
import{HttpTestingController, HttpClientTestingModule} from '@angular/common/http/testing';
import { AuthService } from './auth.service';
import { Router } from '@angular/router';
import { RouterTestingModule } from '@angular/router/testing';
import { HeaderSetter } from '../data/header-setter';

describe('AuthService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule,RouterTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, AuthService],
    ( authService: AuthService) => {
      expect(authService).toBeTruthy();
  })));
});
