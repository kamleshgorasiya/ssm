import { TestBed,async,inject } from '@angular/core/testing';

import { PaymentService } from './payment.service';
import { HttpTestingController, HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from '../data/header-setter';

describe('PaymentService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, PaymentService],
    (categoryService: PaymentService) => {
      expect(categoryService).toBeTruthy();
  })));
});
