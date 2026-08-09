import { beforeEach, describe, expect, it, vi } from 'vitest';
import { useCalculatorStore } from './calculatorStore';

vi.mock('../api/calculateShadow', () => ({
  calculateShadow: vi.fn().mockResolvedValue({
    sunsetTime: 1234567890,
    sunriseTime: 1234560000,
    isPolar: false,
    azimuthProfiles: [],
    sunPath: [],
  }),
}));

describe('calculatorStore', () => {
  const initialState = useCalculatorStore.getState();

  beforeEach(() => {
    useCalculatorStore.setState(
      {
        ...initialState,
        position: null,
        turnstileToken: null,
        error: null,
        sunsetTime: null,
        sunriseTime: null,
      },
      true,
    );
  });

  it('when setPosition is called, position is set and calculation results are reset', () => {
    useCalculatorStore.setState({ sunsetTime: 999, error: 'some_error' });

    useCalculatorStore.getState().setPosition({ lat: 35.0, lng: 135.0 });

    const state = useCalculatorStore.getState();
    expect(state.position).toEqual({ lat: 35.0, lng: 135.0 });
    expect(state.timezone).toBeTruthy();
    expect(state.sunsetTime).toBeNull();
    expect(state.error).toBeNull();
  });

  it('calling calculate without position results in an error', async () => {
    useCalculatorStore.setState({ turnstileToken: 'dummy-token' });

    await useCalculatorStore.getState().calculate();

    expect(useCalculatorStore.getState().error).toBe('error_no_position');
  });

  it('calling calculate without a token results in an error', async () => {
    useCalculatorStore.setState({ position: { lat: 35.0, lng: 135.0 } });

    await useCalculatorStore.getState().calculate();

    expect(useCalculatorStore.getState().error).toBe('error_no_turnstile');
  });

  it('when conditions are met, calculate succeeds and state is updated', async () => {
    useCalculatorStore.setState({
      position: { lat: 35.0, lng: 135.0 },
      turnstileToken: 'dummy-token',
    });

    await useCalculatorStore.getState().calculate();

    const state = useCalculatorStore.getState();
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();
    expect(state.sunsetTime).toBe(1234567890);
    expect(state.sunriseTime).toBe(1234560000);
  });
});
